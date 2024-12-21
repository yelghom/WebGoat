apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-dockerhub-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-dockerhub-app
  template:
    metadata:
      labels:
        app: my-dockerhub-app
    spec:
      containers:
      - name: my-container
        image: yelghom/webgoat:latest
        ports:
        - containerPort: 8080 