#!/bin/bash

# Add additional properties to custom.properties and then call the original entrypoint.sh
if [ -f "nm/services/${TSNM_CAPABILITY}/conf/additional-custom.properties" ]; then
    echo "Adding properties from nm/services/${TSNM_CAPABILITY}/conf/additional-custom.properties to nm/services/${TSNM_CAPABILITY}/conf/custom.properties"
    cat "nm/services/${TSNM_CAPABILITY}/conf/additional-custom.properties" >> "nm/services/${TSNM_CAPABILITY}/conf/custom.properties"
else
    echo "File nm/services/${TSNM_CAPABILITY}/conf/additional-custom.properties not found. No additional properties to add to nm/services/${TSNM_CAPABILITY}/conf/custom.properties"
fi

exec ./entrypoint.sh