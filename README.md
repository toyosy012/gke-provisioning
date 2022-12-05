## GKE プロビジョニング

### 要件(developブランチでcommitする)

1. gke clusterの作成を含むgcpへの作業はgithub actionsからのみ可能
2. k8sリソースはgithub actionsからのみapply可能
3. 外部からアクセスする場合、ingressなどを使用して必要なアクセスのみを通す
4. dashboard系はSSO(Single Sing On)でのみアクセス可能

### Service Account作成

- 下記の作業は手動で行う
- 最小権限のロールを付与

1. `Cloud Resource Manager API`の有効化
2. 作成用Service Accountに`Project IAM 管理者`ロールを付与

### GEK クラスター作成

1. `Kubernetes Engine API`の有効化
2. 作成用Service Accountに`Kubernetes Engine 管理者`ロールを付与
3. 作成用Service Accountに`サービス アカウント管理者`ロールを付与

### 踏み台用ファイアーウォール

1. 作成用Service Accountにファイアーウォール作成用`Compute 管理者(compute.firewalls.create)`ロールを付与
2. 作成用Service AccountにGKEネットワークへのポリシーアップデート用`Compute 管理者(compute.networks.updatePolicy)`
3. 作成用Service Accountにsshホスト接続用`IAP で保護されたトンネル ユーザー(iap.tunnelResourceAccessor)`ロール付与

### IAPトンネル

- 踏み台用サーバーにtinyproxyを起動
- トラフィックをcluster コントロールプレーンにトンネル

```
# inyproxyのインストールと起動を行わない場合は踏み台にsshして、インストール&設定&起動を行う
$ gcloud compute ssh BATION_INSTANCE_NAME --tunnel-through-iap --project=PROJECT_ID
$ sudo apt install tinyproxy
$ sudo echo "Allow localhost" >> /etc/tinyproxy/tinyproxy.conf
$ sudo service tinyproxy restart

# 限定公開クラスターの認証情報取得
$ gcloud container clusters get-credentials CLUSTER_NAME \
    --region=COMPUTE_REGION \
    --project=PROJECT_ID
$ gcloud beta compute ssh BATION_INSTANCE_NAME \
    --tunnel-through-iap \
    --project=PROJECT_ID \
    --zone=COMPUTE_ZONE \
    -- -4 -L8888:localhost:8888 -N -q -f
$ export HTTPS_PROXY=localhost:8888
$ kubectl get ns

# クリーンアップ
$ unset HTTPS_PROXY
```
