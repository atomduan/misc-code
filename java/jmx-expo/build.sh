export JAVA_HOME=/opt/openjdk1.8.202
export M2_HOME=/opt/apache-maven-3.6.0
export PATH=$M2_HOME/bin:$PATH

mvn -U clean package 
