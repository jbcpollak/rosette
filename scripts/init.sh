# install necessary packages to build zenoh-c

sudo apt-get update
sudo apt-get install -y cmake build-essential ninja-build

# build and install zenoh-c
cd golang
git clone https://github.com/eclipse-zenoh/zenoh-c.git
mkdir -p build-zenoh && cd build-zenoh
cmake ../zenoh-c -GNinja
sudo cmake --build . --target install

# install c-for-go that will generate Go bindings for zenoh-c
go install -v github.com/xlab/c-for-go@v1.3.0
