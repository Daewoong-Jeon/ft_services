#rm -rf $HOME/.brew && git clone --depth=1 https://github.com/Homebrew/brew $HOME/.brew && export PATH=$HOME/.brew/bin:$PATH && brew update && echo "export PATH=$HOME/.brew/bin:$PATH" >> ~/.zshrc

#brew install minikube
minikube start --driver=virtualbox
minikube status
MINIKUBE_IP=$(minikube ip)
eval $(minikube -p minikube docker-env)

echo "metalLB setup start"
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
sed "s/MINIKUBE_IP/$MINIKUBE_IP/g" srcs/metallb-config_format.yaml > srcs/metallb-config.yaml
kubectl apply -f srcs/metallb-config.yaml
#kubectl apply -f metallb-config.yaml >> $LOG_PATH

echo "nginx setup start"
docker build -t alpine-nginx srcs/nginx/
kubectl apply -f ./srcs/nginx/nginx_format.yaml

echo "mysql setup start"
docker build -t alpine-mysql srcs/mysql/
kubectl apply -f ./srcs/mysql/mysql.yaml

echo "wordpress setup start"
docker build -t alpine-wordpress srcs/wordpress/
kubectl apply -f ./srcs/wordpress/wordpress_format.yaml

#echo "phpmyadmin setup start"
#docker build -t alpine-phpmyadmin srcs/phpmyadmin/
#kubectl apply -f ./srcs/phpmyadmin/phpmyadmin_format.yaml
kubectl get all
