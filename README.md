## GKE プロビジョニング

### Service Account作成

- 下記の作業は手動で行う
- 最小権限のロールを付与

1. `Cloud Resource Manager API`の有効化
2. 作成用Service Accountに`Project IAM 管理者`ロールを付与

### GEK クラスター作成

1. `Kubernetes Engine API`の有効化
2. 作成用Service Accountに`Kubernetes Engine 管理者`ロールを付与
3. 作成用Service Accountに`サービス アカウント ユーザー`ロールを付与
