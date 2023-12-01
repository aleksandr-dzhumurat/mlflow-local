import os

from minio import Minio
from minio.error import InvalidResponseError, S3Error

accessID = os.environ.get('AWS_ACCESS_KEY_ID')
accessSecret =  os.environ.get('AWS_SECRET_ACCESS_KEY')
minioUrl =  os.environ.get('MLFLOW_S3_ENDPOINT_URL')
bucketName =  os.environ.get('AWS_BUCKET_NAME')

if  None in (accessID, accessSecret, minioUrl, bucketName):
    print("""
        [!] environment variable is empty! run \'source .env\' to load it from the .env file
        AWS_ACCESS_KEY_ID=
        AWS_SECRET_ACCESS_KEY=
        MLFLOW_S3_ENDPOINT_URL=
        AWS_BUCKET_NAME=
    """ % (accessID, accessSecret, minioUrl, bucketName))
    raise RuntimeError

minioUrlHostWithPort = minioUrl.split('//')[1]
print('[*] minio url: ',minioUrlHostWithPort)

s3Client = Minio(
    minioUrlHostWithPort,
    access_key=accessID,
    secret_key=accessSecret,
    secure=False
)

try:
    s3Client.make_bucket(bucketName)
except S3Error as e:
    print(e)

print(f"buckercreated: {bucketName}")