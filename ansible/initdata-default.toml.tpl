# NOTE: This template assumes same-cluster deployment where Trustee/KBS runs
# on the same cluster as the CoCo workloads. For multi-cluster deployments
# (Trustee on separate trusted cluster), the KBS URL would need to use the
# external route: https://kbs.{{ hub_domain }}
#
# Using internal service URL avoids hairpin NAT issues where nodes cannot
# reach the cluster's own public ingress IP from inside the VNet.

algorithm = "sha384"
version = "0.1.0"

[data]
"aa.toml" = '''
[token_configs]
[token_configs.coco_as]
url = "https://kbs-service.trustee-operator-system.svc.cluster.local:8080"

[token_configs.kbs]
url = "https://kbs-service.trustee-operator-system.svc.cluster.local:8080"
cert = """
{{ trustee_cert }}
"""
'''

"cdh.toml"  = '''
socket = 'unix:///run/confidential-containers/cdh.sock'
credentials = []

[kbc]
name = "cc_kbc"
url = "https://kbs-service.trustee-operator-system.svc.cluster.local:8080"
kbs_cert = """
{{ trustee_cert }}
"""
'''

"policy.rego" = '''
package agent_policy

default AddARPNeighborsRequest := true
default AddSwapRequest := true
default CloseStdinRequest := true
default CopyFileRequest := true
default CreateContainerRequest := true
default CreateSandboxRequest := true
default DestroySandboxRequest := true
default GetMetricsRequest := true
default GetOOMEventRequest := true
default GuestDetailsRequest := true
default ListInterfacesRequest := true
default ListRoutesRequest := true
default MemHotplugByProbeRequest := true
default OnlineCPUMemRequest := true
default PauseContainerRequest := true
default PullImageRequest := true
default ReadStreamRequest := true  # TEMPORARY: enabled for debugging sealed secrets issue
default RemoveContainerRequest := true
default RemoveStaleVirtiofsShareMountsRequest := true
default ReseedRandomDevRequest := true
default ResumeContainerRequest := true
default SetGuestDateTimeRequest := true
default SetPolicyRequest := true
default SignalProcessRequest := true
default StartContainerRequest := true
default StartTracingRequest := true
default StatsContainerRequest := true
default StopTracingRequest := true
default TtyWinResizeRequest := true
default UpdateContainerRequest := true
default UpdateEphemeralMountsRequest := true
default UpdateInterfaceRequest := true
default UpdateRoutesRequest := true
default WaitProcessRequest := true
default WriteStreamRequest := true
default ExecProcessRequest := true  # TEMPORARY: enabled for debugging sealed secrets issue
# default ExecProcessRequest := false # Intended value
default SetPolicyRequest := false
default WriteStreamRequest := false

ExecProcessRequest if {
    input_command = concat(" ", input.process.Args)
    some allowed_command in policy_data.allowed_commands
    input_command == allowed_command
}

policy_data := {
  "allowed_commands": [
        "curl http://127.0.0.1:8006/cdh/resource/default/attestation-status/status",
        "curl http://127.0.0.1:8006/cdh/resource/default/attestation-status/random"
  ]
}
'''