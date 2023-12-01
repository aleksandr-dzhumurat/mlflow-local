FROM adzhumurat/mlflow_local:dev

WORKDIR /srv/

RUN \
    python3.11 -m pip install --no-cache jupyter

CMD ["jupyter", "notebook", "src/jupyter_notebooks", "--ip", "0.0.0.0", "--port", "8888", "--allow-root", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]