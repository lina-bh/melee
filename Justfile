kubeconfig:
	ssh root@melee.lamancha-alhena.ts.net -- \
		sudo cat /etc/rancher/k3s/k3s.yaml | \
		yq ' \
		(.. | select(. == "default")) = "melee" \
		| .clusters[].cluster.server = "https://melee.lamancha-alhena.ts.net:6443"' \
	> "{{ justfile_directory() }}/.kube/config"
	env KUBECONFIG="${HOME}/.kube/config:{{ justfile_directory() }}/.kube/config" kubectl config view --flatten | yq '.current_context = "melee"' > "${HOME}/.kube/config"
