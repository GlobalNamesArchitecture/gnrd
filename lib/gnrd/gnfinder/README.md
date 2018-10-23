# gRPC based connection to `gnfinder`

To compile ruby code

```bash
cd ./ruby
bundle
grpc_tools_ruby_protoc -I $GOPATH/src/github.com/gnames/gnfinder/protob --ruby_out=. --grpc_out=. \
../../../protob/protob.proto