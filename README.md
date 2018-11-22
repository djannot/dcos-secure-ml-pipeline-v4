# DC/OS Secure ML Pipeline v3

In the [first version](https://github.com/djannot/dcos-secure-ml-pipeline), I was explaining how to deploy Apache HDFS, ZooKeeper, Kafka and Spark with TLS and Kerberos.

And I was using a simple Spam/Ham Scala Application to demonstrate how to deploy Spark jobs using the DCOS CLI (**dcos spark run**).

In the second version, I've added Apache NiFi and the [Jupyter](http://jupyter.org/) notebook to provide additional capabilities and a better user experience.

In this new version, I use Apache NiFi to get some pictures of cats and dogs from the Flickr API, store them in HDFS, retrain a Tensorflow model to classify these new categories and use a CI/CD pipeline (using Gitlab and Jenkins) to deploy on Kubernetes a web application leveraging this model.

The previous demos are also available in this repo.

## Prerequisites

You need to provision a DC/OS Enterprise Edition cluster in either `permissive` or `strict` mode.

A DC/OS cluster with at least 10 private agents providing 40 CPU and 128 GB of RAM is required.

If you deploy it in strict mode, you need to setup the DCOS cli using `https` (dcos cluster setup `https://`).


## Deployment

You simply need to execute the following command:

```
./deploy-all.sh
```

It will deploy Apache HDFS, Kafka (with its own dedicated ZooKeeper), Spark, NiFi and Jupyter with Kerberos and TLS.

A `KDC` will also be deployed, but if you'd like to reuse the same approach to deploy this stack in production, you would skip this step and use your own KDC (which could be Active Directory, for example).

## Flickr demo

Run the following command to launch NiFi in your web browser:

```
./open-NiFi.sh
```

Login with `NiFiadmin@MESOS.LAB` using the password `password`.

![NiFi](images/NiFi.png)

Right click on the background.

![NiFi-templates](images/NiFi-templates.png)

Select `Upload template` and upload the `Flickr.xml` template.

![NiFi-upload-template-flickr](images/NiFi-upload-template-flickr.png)

Drag and drop the template icon and select the `Flickr.xml` template.

![NiFi-add-template-flickr](images/NiFi-add-template-flickr.png)

As you can see, there are few warnings. They are corresponding to the sensitive information that can't be stored in a template.

![NiFi-template-flickr](images/NiFi-template-flickr.png)

Double click on the `Get Recent Flickr Pictures` group.

![NiFi-get-recent-flickr-pictures](images/NiFi-get-recent-flickr-pictures.png)

Double click on the first `InvokeHTTP` processor.

![NiFi-invoke-http](images/NiFi-invoke-http.png)

Then, click on the arrow in the `SSL Context Service` row.

![NiFi-invoke-http-ssl](images/NiFi-invoke-http-ssl.png)

Click on the `Configure` icon.

![NiFi-invoke-http-ssl-password](images/NiFi-invoke-http-ssl-password.png)

Indicate `changeit` for the truststore password.

![NiFi-invoke-http-ssl-enable](images/NiFi-invoke-http-ssl-enable.png)

Click on the `Enable` icon and enable it.

Double click on the first `GenerateFlowFile` processor.

![NiFi-cat](images/NiFi-cat.png)

Specify `cats` for the value of the `tags` parameter.

Go back to the main screen by clicking on `NiFi Flow` on the bottom left.

Select all the components and copy and paste to duplicate the workflow.

Update the `tags` parameter of the `GenerateFlowFile` processor of the second workflow with the value `dog`.

Go back to the main screen by clicking on `NiFi Flow` on the bottom left.

Select all the components and click on the play button.

Run the following command to launch the Jupyter notebook in your web browser:

```
./open-jupyterlab.sh
```

The password is `jupyter`

![jupyter-launcher](images/jupyter-launcher.png)

Click on the `Terminal` icon to launch a terminal inside the Notebook.

Run the following command until you get around 2000 results (which means 2000 pictures) and stop the NiFi workflow.

```
hdfs dfs -ls -R /user/nobody/flickr | grep wc -l
2000
```

Go to `~/server-model` and edit the Jenkins file to update the value of the token which the one that has been returned by the deployment script:

```
Data
====
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJkZWZhdWx0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6ImplbmtpbnMtc2VjcmV0Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImplbmtpbnMiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiIyZjAwNGRiMS1jMTkzLTExZTgtYjBjMS0wNjE0ZmVlYTljMjAiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6ZGVmYXVsdDpqZW5raW5zIn0.SBk2PXirHMgzQufznAp7hq7KZ53wXrzmnqJ1IzUKosYggGuTaCLIquPwZt765fzfoCIjyVtR0EJB-drlQQeU8CC1MiuYtUoFHNWW3ArOIw54uk50mtaoFHkY2N1Cte_rSFp45Tq6MqC5O41TmjlekkQ3AhFjTGArfZHtd5vayzk1fKYVLd69DF26NuXqrgPH0agnXQ02TL6jhGdHj1Ptnm50CbkGyfIWLG4zfzKTa_mPirjBXfxKn7yJKrr4-Hr3hGNGN4JrNlxJxETqHqZA6K_UddsPiRf12Ws5kpZV6tHi-h9D5jh952fU6rRQfx43oFoeuZuyQyZsJBcu91Wn5g
```

Run the following command to launch gitlab in your web browser:

```
./open-gitlab.sh
```

Set the password to `password`, login with the user `root` and this password and create a new public project called `serve-model`.

Go back to the terminal in the Jupyter lab notebook and run the following command to initialize the git repo.

```
git config --global user.name "Administrator"
git config --global user.email "admin@example.com"
git init
git remore add origin http://x.x.x.x:10080/root/server-model.git
git add .
git commit -a -m "First commit"
git push -u origin master
```

You need to replace `x.x.x.x` by the IP of your setup you can find in the URL of gitlab.

Run the following command to launch jenkins in your web browser:

```
./open-jenkins.sh
```

Go to `Credentials` -> `System` -> `Global credentials (unrestricted)` -> `jenkins/******` and click on `Delete`.

Go to `Credentials` -> `System` -> `Global credentials (unrestricted)` and click on `Add Credentials`.

Specify `root` and `password` as the username and password and set the `ID` to `gitlab`.

Go to `Credentials` -> `System` -> `Global credentials (unrestricted)` and click on `Add Credentials`.

Specify your Docker Hub username and password and set the `ID` to `dockerhub`.

Go back to the main page and click on `Manage Jenkins` and then on `Configure System`.

Check the `Environment variables` box and add a new one called `DOCKERHUB_REPO` with the name of the Docker repository you want to use (something like `yourdockerhubusername/serve-model`).

At the bottom, in the `cloud` section, click on `Add` right to the `Framework credentials option`.

Specify `jenkins` and `password` as the username and password leave the rest blank.

Finally, select the `credentials` you've just created.

Click on `Apply` and then on `Save`.

You can now create the Jenkins pipeline that will build the Docker image when a new commit is pushed to the gitlab repo.

Go back to the main page and click on `New Item`.

Call it `serve-model`, select `Pipeline` and click on `OK`.

Check the `Poll SCM` box and set the value to `* * * * *`.

![jenkins-poll-scm](images/jenkins-poll-scm.png)

In the `Pipeline` section, select `Pipeline script from SCM` and then `Git` as the SCM.

Specify the gitlab repo URL and the `root/******` credentials.

![jenkins-git](images/jenkins-git.png)

Click on `OK`.

Go back to the terminal in the Jupyter lab notebook.

Download the Tensorflow script in the home directory to retrain the image classifier.

```
cd ~
curl -LO https://github.com/tensorflow/hub/raw/master/examples/image_retraining/retrain.py
```

Retrain the model by indicating the path where the files have been uploaded in HDFS.

```
python retrain.py --image_dir hdfs://hdfs/user/nobody/flickr
```

When the scripts terminates, upload the model generated under `~/serve-model` and push a new commit in the git repo.

```
cd ~/serve-model
cp /tmp/output*
git add .
git commit -a -m "With model"
git push
```

This will trigger the jenkins pipeline.

![jenkins-build](images/jenkins-build.png)

Run the following command to launch the Kubernetes Dashboard in your web browser:

```
./open-kubernetes-dashboard.sh
```

You should see the 2 pods created by jenkins.

![kubernetes-dashboard](images/kubernetes-dashboard.png)

Run the following command to launch the Traefik Ingress UI in your web browser:

```
./open-traefik.sh
```

You should see the Ingress created by jenkins

![traefik](images/traefik.png)

Run the following command to launch the web application in your web browser:

```
./open-web-app.sh
```

Upload a picture of a cat or a dog and check if the model you retrain works well.

![cat](images/cat.png)

## Spam/Ham demo

This is the demo that was available in the previous [repo](https://github.com/djannot/dcos-secure-ml-pipeline)

The `deploy-all.sh` script is executing the `create-model.sh` and `generate-messages.sh` scripts.

The `create-model.sh` script creates the model using Spark and the `SMSSpamCollection.txt` text file that contains examples of spams and hams. This file has already been uploaded to an Amazon S3 bucket to simplify the process. 

The model is stored in `HDFS`.

The `generate-messages.sh` script generates new random messages. It is another Spark job and it's also leveraging the `SMSSpamCollection.txt` file to generate them. These messages are produced in Kafka.

### Option 1 - classify the messages using `dcos spark run`

Finally, you can run the following script to use the model previously created to classify the incoming messages. It will consume the messages from Kafka and will display the accuracy of the process in `stdout`.

```
./classify-messages.sh
```

To access `stdout`, you click on the arrow close to the Spark service:

![dcos](images/dcos.png) 

Then, you click on the `Sandbox` link corresponding to the `SpamHamStreamingClassifier` driver:

![spark](images/spark.png)

Finally, you click on `stdout`:

![mesos](images/mesos.png)

You can see the accuracy displayed at the end of the log:

![log](images/log.png)

Stop the Spark job using `dcos spark kill` to free resources.

The 3 Spark jobs are using a jar file that has also been uploaded to an Amazon S3 bucket to simplify the process.

The source code is available [here](https://github.com/djannot/spark-build/blob/master/tests/jobs/scala/src/main/scala/SpamHam.scala).

The `hdfs-client.txt` and the `kafka-client.txt` files are showing the commands you need to use if you want to check the files stored in HDFS and the messages produced in Kafka.

A video going through the full demo is available on YouTube [here](https://www.youtube.com/watch?v=WMISqFRk28E).

### Option 2 - classify the messages using the Jupyter notebook

One of the advantage of this approach is that a data scientist can work on his code and submit it without compiling a new jar.

Run the following command to launch it in your web browser:

```
./open-jupyterlab.sh
```

The password is `jupyter`

![jupyter-launcher](images/jupyter-launcher.png)

Click on the `Terminal` icon and run the following command:

```
klist
```

The output should be as below:

```
Ticket cache: FILE:/tmp/krb5cc_65534
Default principal: client@MESOS.LAB

Valid starting       Expires              Service principal
08/16/2018 10:43:02  08/17/2018 10:43:02  krbtgt/MESOS.LAB@MESOS.LAB
```

As you can see, the deployment script has logged you in as `client@MESOS.LAB` (using `kinit -kt merged.keytab client@MESOS.LAB`).

In a real production environment, you would login with your Active director user (for example).

The script has also uploaded the Kerberos TGT (Ticket Granting Ticket) to the DC/OS secret store.

![secret](images/secret.png)

This TGT will be used by Spark to authenticate against Apache Kafka and HDFS.

This is define in the `JAAS_ARTIFACT.conf` file:

```
KafkaClient {
    com.sun.security.auth.module.Krb5LoginModule required
    useKeyTab=false
    useTicketCache=true
    ticketCache="/mnt/mesos/sandbox/tgt"
    renewTGT=true
    serviceName="kafka"
    principal="client@MESOS.LAB";
}; 
```

You can now open the `dcos-secure-ml-pipeline.ipynb` file.

![jupyter-dcos-secure-ml-pipeline](images/jupyter-dcos-secure-ml-pipeline.png)

As you can see on the top right corner, this is using the [Apache Toree](https://toree.incubator.apache.org/) - Scala kernel.

Run the 3 first paragraphs.

You should see the result displayed as shown below:

![jupyter-dcos-secure-ml-pipeline-output](images/jupyter-dcos-secure-ml-pipeline-output.png)

Note that this is not using the DC/OS Spark package.

The Jupyter notebook container is the Spark driver.

Click on `Kernel` -> `Shutdown Kernel` to stop the Spark job.

You can (optionaly and after restarting the Kernel) run the last paragraph to consume the Kafka topic and see the type of messages classified by the model.

## Twitter sentiment analysis demo

This is the demo that was available in the previous [repo](https://github.com/djannot/dcos-secure-ml-pipeline-v2)

To run the new Twitter demo, you need to obtain your Twitter Consumer and Access Keys and Secrets.

You can obtain them by appling for a Twitter developer account at [https://developer.twitter.com/en/apply-for-access](https://developer.twitter.com/en/apply-for-access).

You then need to wait before Twitter approves it.

In this demo, I'm also leveraging Apache NiFi and the Jupyter notebook to provide additional capabilities and a better user experience.

Apache NiFi is used to listen to the Twitter Streaming API, produce the tweets in Kafka and store them in HDFS.

The Jupyter notebook is then used to create create a model.

Run the following command to launch NiFi in your web browser:

```
./open-NiFi.sh
```

Login with `NiFiadmin@MESOS.LAB` using the password `password`.

![NiFi](images/NiFi.png)

Right click on the background.

![NiFi-templates](images/NiFi-templates.png)

Select `Upload template` and upload the `TwitterKafkaHDFS.xml` template.

![NiFi-upload-template](images/NiFi-upload-template.png)

Drag and drop the template icon and select the `TwitterKafka10HDFS.xml` template.

![NiFi-add-template](images/NiFi-add-template.png)

As you can see, there are few warnings. They are corresponding to the sensitive information that can't be stored in a template.

![NiFi-template](images/NiFi-template.png)

Double click on the `PublishKafka_0_10` processor.

![NiFi-kafka](images/NiFi-kafka.png)

Then, click on the arrow in the `SSL Context Service` row.

![NiFi-kafka-ssl](images/NiFi-kafka-ssl.png)

Click on the `Configure` icon.

![NiFi-kafka-ssl-password](images/NiFi-kafka-ssl-password.png)

Indicate `changeit` for the truststore password.

![NiFi-kafka-ssl-enable](images/NiFi-kafka-ssl-enable.png)

Click on the `Enable` icon and enable it.

Double click on the `Twitter Data Source`.

![NiFi-twitter](images/NiFi-twitter.png)

Then, double click on the `GetTwitter` processor.

![NiFi-twitter-credentials](images/NiFi-twitter-credentials.png)

Indicate your Consumer and Access Keys and Secrets.

Select all the components and click on the play button.

![NiFi-run](images/NiFi-run.png)

After few minutes, click on the stop button to make sure you don't write in Kafka more data than the space available on it.

Run the following command to launch the Jupyter notebook in your web browser:

```
./open-jupyterlab.sh
```

The password is `jupyter`

![jupyter-launcher](images/jupyter-launcher.png)

Click on `Help` and select `Launch Classic Notebook`.

We launch the classic notebook to be able to use the `Spark Magic` extension.

Open the `TwitterSentimentAnalysisCreateModel.ipynb` file.

![twitter-create-model](images/twitter-create-model.png)

Run the first paragraph.

Update the date in the third paragraph. It should reflect today's date.

Then, click on `Kernel` and select `Restart & Run All`.

Now that we have created a Twitter Sentiment Analsis model and stored it in HDFS, we can apply it the tweets consumed through Kafka.

Click on `Kernel` -> `Shutdown Kernel` to stop the Spark job.

Go back to the default Jupyter Notebook (not the Classic one) and open the `TwitterSentimentAnalysisApplyModel.ipynb` file.

![twitter-apply-model](images/twitter-apply-model.png)

Run the paragraph.

![twitter-result](images/twitter-result.png)


