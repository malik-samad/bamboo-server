# Use the official Bamboo image as the base
FROM atlassian/bamboo-server:9.1.1

# Install MySQL client and server
RUN apt-get update && \
    apt-get install -y mysql-server mysql-client default-jre && \
    wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.27.tar.gz && \
    tar -xzf mysql-connector-java-8.0.27.tar.gz && \
    mv mysql-connector-java-8.0.27/mysql-connector-java-8.0.27.jar /opt/atlassian/bamboo/atlassian-bamboo/WEB-INF/lib/ && \
    rm -rf mysql-connector-java-8.0.27 mysql-connector-java-8.0.27.tar.gz \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure MySQL
COPY mysql.cnf /etc/mysql/conf.d/mysql.cnf
RUN service mysql start && \
    mysql -e "CREATE DATABASE bamboo CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;" && \
    mysql -e "CREATE USER 'bamboo'@'localhost' IDENTIFIED BY 'password';" && \
    mysql -e "GRANT ALL PRIVILEGES ON bamboo.* TO 'bamboo'@'localhost';"

# Configure Bamboo to use MySQL
ENV BAMBOO_JDBC_URL=jdbc:mysql://localhost:3306/bamboo?useUnicode=true&characterEncoding=utf8&useSSL=false
ENV BAMBOO_JDBC_DRIVER=com.mysql.jdbc.Driver
ENV BAMBOO_JDBC_USER=bamboo
ENV BAMBOO_JDBC_PASSWORD=password

# Logs
RUN echo %JAVA_HOME%

# Expose the necessary ports
EXPOSE 8085
EXPOSE 3306

# Start Bamboo server and MySQL server
CMD service mysql start && /opt/atlassian/bamboo/bin/start-bamboo.sh -fg
