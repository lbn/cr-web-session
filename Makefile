PROTO_PATH=src/session-model

protoc:
	PATH=${PWD}:${PATH} protoc -I ${PROTO_PATH} ${PROTO_PATH}/*.proto --crystal_out ${PROTO_PATH}
