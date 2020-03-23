FROM confluentinc/cp-kafka-connect:5.4.1

RUN confluent-hub install --no-prompt debezium/debezium-connector-mysql:0.10.0
RUN cp /usr/share/confluent-hub-components/debezium-debezium-connector-mysql/lib/mysql-connector-java-8.0.16.jar \
    /usr/share/java/kafka

