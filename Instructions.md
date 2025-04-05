#### Install Java: On the same VM, install Java:
```
sudo apt update
sudo apt install fontconfig openjdk-17-jre
java -version
openjdk version "17.0.13" 2024-10-15
OpenJDK Runtime Environment (build 17.0.13+11-Debian-2)
OpenJDK 64-Bit Server VM (build 17.0.13+11-Debian-2, mixed mode, sharing)
```
#### Install Jenkins:
```
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```
#### Access Jenkins: Open a browser and go to http://pip:8080.
```
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### 🛠️ Step 3: Install Docker on the Ubuntu VM
```
sudo apt update
sudo apt install -y docker.io
```
#### Allow Jenkins to use Docker:
```
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```
#### Verify Docker installation:
```
docker --version
```