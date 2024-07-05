#!/usr/bin/env sh

set -o errexit
set -o nounset
set -o pipefail

# Shutdown the tests gracefully then save the results
# shellcheck disable=SC2317 # false positive
shutdown () {
    OCI_SUITE_PID=$(pgrep conformance.test)
    echo "sending TERM to ${OCI_SUITE_PID}"
    kill -s TERM "${OCI_SUITE_PID}"

    # Kind of a hack to wait for this pid to finish.
    # Since it's not a child of this shell we cannot use wait.
    tail --pid "${OCI_SUITE_PID}" -f /dev/null
    saveResults
}

saveResults() {
    cd "${RESULTS_DIR}" || exit
    tar -czf oci.tar.gz ./*
    # mark the done file as a termination notice.
    echo -n "${RESULTS_DIR}/oci.tar.gz" > "${RESULTS_DIR}/done"
}

# Optional Golang runner alternative to the bash script.
# Entry provided via env var to simplify invocation.

# We get the TERM from kubernetes and handle it gracefully
trap shutdown TERM


set -x
./conformance.test -ginkgo.focus="${OCI_FOCUS}" -ginkgo.noColor  > >(tee "${RESULTS_DIR}"/oci.log) && ret=0 || ret=$?
set +x
saveResults
exit "${ret}"