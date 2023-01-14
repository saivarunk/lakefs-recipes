# lakeFS Setup with AWS DynamoDB & S3

This repo contains code snippets used in the blog post:
[https://varunkruthiventi.medium.com/version-control-for-data-lake-with-lakefs-69f350444f3f](https://varunkruthiventi.medium.com/version-control-for-data-lake-with-lakefs-69f350444f3f)

## Creating AWS Resource

```bash
terraform int
```

```bash
terraform plan
```

```bash
terraform apply
```

## Starting lakeFS

```bash
docker-compose up
```

## Removing AWS Resources

```bash
terraform apply -destroy
```
