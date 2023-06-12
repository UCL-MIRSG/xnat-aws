### Configure AWS infrastrucre using Ansible

After creating the infrastructure using Terraform, we can configure it for XNAT deploying using the following command:

```bash
ansible-playbook app.yml -u ec2-user --key-file '../ssh/aws_rsa.pem' -i hosts.yml --ssh-common-args='-o StrictHostKeyChecking=accept-new'
```

**Note**, we set `StrictHostKeyChecking=accept-new` to automatically accept fingerprints for new hosts. This means we still do host key checking but we do not need to explicitly accept keys for new hosts.
