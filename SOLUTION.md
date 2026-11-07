```markdown
## Task 1 — Terraform

### 1a: NACL Fixes
        - saya membuat aws_network_acl_rule baru untuk subnet pods
        - rule number beberapa ada yang sama, tidak masalah jika egrees type nya berbeda

### 1b: RDS Module — Bugs Fixed
        - menambahkan aws_security_group_rule agar antar AWS resource diallow via SG to SG.
        - DB parameter group rds.force_ssl untuk encrypted connection RDS
        - idle_client_timeout saya buat 1800 agar connection dapat digunakan berulang dengan asumsi timeout pada aplikasi lebih kecil
        - iam_auth DISABLED karena app menggunakan username/password dari Secret Manager

### 1b: RDS Proxy — Design Decisions
[your answer]

## Task 2 — Kubernetes

### 2a: NodePool Design Decisions
        - pada karpenter.sh/capacity-type pemilihan node diprioritaskan pada SPOT instance karena jauh lebih murah, dan kebutuhan app juga stateless
        - key: karpenter.k8s.aws/instance-category memilih instance yang "compute optimized"
        - budgets.nodes: "20%" adalah total node dari limit 20 berarti 4 node yang dapat sewaktu-waktu terkena recycle, karena sifat SPOT instance yang sewaktu-waktu bisa diambil oleh AWS

### 2b: KEDA ScaledObject — Bugs Fixed
        - karpenter.sh/capacity-type hanya menggunakan ON-DEMAND instance, karena kebutuhan yang stateful
        - pemilihan instance family diprioritaskan yang memory-optimized

## Task 3 — Incident

### 3a: Root Cause Analysis
        - traffic dari pods ke Database dan Redis belum diallow di NACL, hanya subnet 10.10.64.0/20 (app) node saja tetapi subnet pods belum
        - DB proxy menggunakan subnet milik web "subnet-0web1aaa","subnet-0web2bbb","subnet-0web3ccc" dan bisa dilihat pada error 
            Error: connect ETIMEDOUT 10.10.16.45:5432 yang mana IP tersebut bukan dari bagian subnet protected
        - konfigurasi redis cluster mengharusnya menggunakan TLS/SSL: 
             "TransitEncryptionEnabled": true,
            "TransitEncryptionMode": "required",
            "AtRestEncryptionEnabled": true
            tetapi pada configmap app "REDIS_SSL: "false" dan harus dirubah ke "true".

### 3b: Remediation Plan
        1. dengan cara fix NACL melalui terraform, saya buat filenya di task3-incident/terraform/fix-nacl.tf
        2. di fix di task3-incident/terraform/fix-subnet.tf, agar DB proxy menggunakan subnet yang sesuai
        3. mengubah value REDIS_SSL pada configmap app

### 3c: Prevention
        1. membuat list subnet dan menghindari penulisan subnet NACL secara hardcode
        2. mungkin bisa divalidate di CI ketika DB proxy menggunakan subnet yang tidak sesuai
        3. untuk validate menggunakan SSL ke endpoint redis belum pernah tau bagaimana caranya
```