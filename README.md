# mlflow-local
Local mlflow instance

Build docker images

```shell
make build
```

Run MLFlow + MinIO (for artifacts) + Jupyter
```shell
make run
```

Open MLFlow in browser
```shell
http://localhost:8000/
```
MinIO interface
```shell
http://localhost:9001/
```

Jupyter interface
```shell
make run-jupyter
```

```shell
http://localhost:8888/
```
