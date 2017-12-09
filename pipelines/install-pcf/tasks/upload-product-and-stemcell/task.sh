#!/bin/bash

set -eu

if [[ -n "$NO_PROXY" ]]; then
  echo "$OM_IP $OPSMAN_DOMAIN_OR_IP_ADDRESS" >> /etc/hosts
fi

if ( cat ./pivnet-product/metadata.json | jq --raw-output ' [ .Dependencies[] | select(.Release.Product.Name | contains("Stemcells")) | .Release.Version ]' 2> /dev/null ) ; then
  STEMCELL_VERSION=$(
    cat ./pivnet-product/metadata.json |
    jq --raw-output \
      '
      [
        .Dependencies[]
        | select(.Release.Product.Name | contains("Stemcells"))
        | .Release.Version
      ]
      | map(split(".") | map(tonumber))
      | transpose | transpose
      | max // empty
      | map(tostring)
      | join(".")
      ' 2> /dev/null
  )
else
  STEMCELL_VERSION=$(
    cat ./pivnet-product/metadata.json |
    jq --raw-output \
      '
      [
        .DependencySpecifiers[]
        | select(.ProductSlug | contains("stemcells"))
        | .Specifier
      ]
      | map(split(".") | map(tonumber))
      | transpose | transpose
      | max // empty
      | map(tostring)
      | join(".")
      '
  )  2> /dev/null
fi

if [ -n "$STEMCELL_VERSION" ]; then
  diagnostic_report=$(
    om-linux \
      --target https://$OPSMAN_DOMAIN_OR_IP_ADDRESS \
      --username $OPS_MGR_USR \
      --password $OPS_MGR_PWD \
      --skip-ssl-validation \
      curl --silent --path "/api/v0/diagnostic_report"
  )

  stemcell=$(
    echo $diagnostic_report |
    jq \
      --arg version "$STEMCELL_VERSION" \
      --arg glob "$IAAS" \
    '.stemcells[] | select(contains($version) and contains($glob))'
  )

  if [[ -z "$stemcell" ]]; then
    echo "Downloading stemcell $STEMCELL_VERSION"

    product_slug=$(
      jq --raw-output \
        '
        if ( .Dependencies ) then
          if any(.Dependencies[]; select(.Release.Product.Name | contains("Stemcells for PCF (Windows)"))) then
            "stemcells-windows-server"
          else
            "stemcells"
          end
        else
          .DependencySpecifiers[]
          | select(.ProductSlug | contains("stemcells"))
          | .ProductSlug
        end
        ' < pivnet-product/metadata.json
    )

    pivnet-cli login --api-token="$PIVNET_API_TOKEN"
    pivnet-cli download-product-files -p "$product_slug" -r $STEMCELL_VERSION -g "*${IAAS}*" --accept-eula

    SC_FILE_PATH=`find ./ -name *.tgz`

    if [ ! -f "$SC_FILE_PATH" ]; then
      echo "Stemcell file not found!"
      exit 1
    fi

    om-linux -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS -u $OPS_MGR_USR -p $OPS_MGR_PWD -k upload-stemcell -s $SC_FILE_PATH
  fi
fi

# Should the slug contain more than one product, pick only the first.
FILE_PATH=`find ./pivnet-product -name *.pivotal | sort | head -1`
om-linux -t https://$OPSMAN_DOMAIN_OR_IP_ADDRESS -u $OPS_MGR_USR -p $OPS_MGR_PWD -k --request-timeout 3600 upload-product -p $FILE_PATH
