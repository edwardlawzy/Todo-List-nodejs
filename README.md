
# FortStark DevOps Internship Assessment: Todo-List-nodejs

This is the FortStark DevOps Internship Assessment submission. In this submission,  we demonstrate the implementation of a CI/CD pipeline using Github Actions, Ansible, Docker Compose, Watchtower, Kubernetes and ArgoCD


## Prerequisites
* A GitHub account.
* A Docker Hub account.
* A MongoDB Atlas database.
## Part 1

* We first need to create a MongoDB database and put the URI in the .env file. The .env will not be pushed to the repo so you need to create your own.
* To dockerize the image, we need to create a docker file and a docker ignore file. We used a node alpine image to be light weight and we installed curl during the building process because we are going to need it for healthcheck.
* We created a Github Action Workflow that is triggered with any commit & push to the main repo which does the following:
     1. Clones the repo, 
     2. Sets up Docker Builx 
     3. Update the deployment.yaml in another repo called "ArgoCD_Deployment" with the updated image tag and then commit and push the edited file to the repo.
     4. Log into Docker Hub and Build & Push the new image under 2 tags: latest & randomly generated string.
* Explanation: We built the image with 2 tags because for ArgoCD to pull and deploy the new image, it has to be a new name but that would break watchtower. So this way both implementations are still functioning
## Part 2
* We create a Linux VM on our local machine using Oracle VirtualBox and assigned a static IP to it.
* Ansible can't be installed directly on Windows, So we installed it on Windows Subsystem for Linux (WSL) and it connects to our VM using SSH. We created 2 playbooks depending on the implementation wanted.
The initial part is the same for both playbooks and it does the following:
1. The playbook will ask for privilege escalation at the start and then checks the type of the linux family. If it's debian it will use apt to update and upgrade the packages and if it is redhat, it will use yum.
2. Install all of Docker dependencies: apt-transport-https, ca-certificates, curl, gnupg, lsb-release.
3. Add Docker's official GPG key to the system's trusted keys.
4. Add Docker's official APT repository to the system's sources list.
5. Install the core Docker components: docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin.
6. Add the current Ansible user (the user that SSHed into the VM) to the 'docker' group.
7. Starts Docker service and configure it to start on boot.
8. Copy _vm.env to VM and rename it to .env.
9. Copy the docker .config file to the VM

Explanation: The app looks for an environment variable for mongodb uri (check _example.env file), so we copy it to the VM from our local machine. As for Docker, it looks for the encoded auth key in the .config file.

## Part 3: Using Docker Compose
In the docker compose file, it pulls the image with tag `:latest` from our private docker hub registry, maps port 4000 to 8080 on our local machine and performs the healthchecks on the container by using `curl -f http://localhost:4000` to see if the app is up and running properly. All of this is also automated using the Ansible playbook.
The playbook does the following steps to automate the deployment using docker compose.
1. Copy the Docker Compose configuration file (`docker-compose.yml`) to the VM.
2. Run the Docker Compose application in detached mode.
3. Copy the Watchtower configuration folder to the VM.
4.  Run the Watchtower Docker container and it will check the docker registry for changes every 5 seconds and with the cleanup flag enabled.

Explanation on why we used Watchtower: It's lightweight, easy to configure & deploy and it gets the job done for small environments but it is not recommended for large environments or enterprise use.

## Part 4: Using Kubernetes and ArgoCD
The following steps are added to the Ansible playbook to automate this implementation.
1. Install Minikube by pulling the `minikube-linux-amd64` file, installing it and then deleting the file. The minikube installer will install kubectl and it's dependencies.
2. Start minikube.
3. Install ArgoCD by creating the `argocd` namespace and applying the argocd services in the argocd namespace by using this command:
`kubectl create namespace argocd && kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
`

4. Add 1 minute delay for ArgoCD server to start.

5. Port forward the ArgoCD Server from port 443 to port 8000 by using the following command.
`kubectl port-forward svc/argocd-server -n argocd 8000:443 &`
and to access the server use `localhost:8000`

6. Copy the Kubernetes folder from local machine to VM which has a secrets.yml files that we will add to Kubernetes (check `Kubernetes/secrets` for examples).

7. Create the MongoDB URI and Docker Hub secrets and delete the files
by using `kubectl apply -f /kubernetes/secrets/secret-mongodb.yaml  && kubectl apply -f /kubernetes/secrets/secret-docker.yaml && rm -r /kubernetes/secrets`

8. Apply Application.yaml which will deploy our kubernetes environment and then apply service.yaml which will give us access to the pod.
`kubectl apply -f /kubernetes/application.yaml && kubectl apply -f /kubernetes/service.yaml`

9. And finally to get the pod IP and port use `minikube service todo-app-node-service --url`

## Flowchart


<img width="886" height="610" alt="FortStark_Assessment1 (3)" src="https://github.com/user-attachments/assets/9ebca81d-67b7-4e45-9757-4a2a98fcea85" />

