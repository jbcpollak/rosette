# Rosette

As of now, this is a rough proof of concept for integrating with ROS2 from outside the ROS workspace, using native Zenoh libraries.

You will separately need a ROS instance running the rmw_zenoh middleware. As of right now, this requires zenoh 0.11.

## Benefits

When flushed out into a full project, this would let you run your control codebase completely independently from the ROS workspace and build system.

This would give a team access to ROS middleware, bagging, transforms drivers and visualization tools without having to compromise on build stack for the team's own code.

Not yet done:
* Topic discovery (not sure how to list all Zenoh or ROS topics)
* .msg or .idl to .py generation (could adapt the code in [rospypi/simple](https://github.com/rospypi/simple))
* Not sure if Zenoh (or ROS2 for that matter) supports latched topics

## Technical Details

Below is an exploration of ROS’s Zenoh messaging and ways to communicate with it from outside ROS or with alternative languages.

Below is an example of the messages seen over Zenoh when using the rmw_zenoh Hello World example.  Using a non-ROS Python library it gives a pretty clear idea of what ROS is doing under the covers:

The Zenoh topic is `0/chatter/std_msgs::msg::dds_::String_/RIHS01_df668c740482bbd48fb39d76a70dfd4bd59db1288021743503259e948f6b1a18` which breaks up into:

* 0: the ROS scope
* chatter/: The ROS topic
* std_msgs::msg::dds_::String_: The message type and serialization standard
* RIHS01_df668c740482bbd48fb39d76a70dfd4bd59db1288021743503259e948f6b1a18: Currently unknown.

The body of the message is encoded in CDR (Common Data Representation) which is the standard DDS uses for serialization but is not exclusive to DDS.

Unfortunately, non DDS-implementations of CDR serialization/deserialization are hard to find.

## Python

We can deserialize ROS messages by writing (or eventually generating) Python classes using the pycdr2 library. pycdr2 is extracted from eclipse-cyclonedds/cyclonedds-python , which is actively maintained, but pycdr2 hasn’t been published in over two years (See is the standalone pycdr2 library still supported?
open
 ), although it seems to still work.

The cyclonedds-python library could be used directly but it requires the native cyclonedds binaries compiled and installed, which is more than necessary for just using the CDR IDL. We could extract the code ourselves.

### Prerequisites

Launch the devcontainer

```
cd python
uv sync
. .venv/bin/activate
```

### Running

Run `python python/z_sub.py -e tcp/172.19.0.2:7447 -k "0/chatter/**"` to subscribe to the chatter topic.

You should see:

```
>> [Subscriber] Received PUT ('0/chatter/std_msgs::msg::dds_::String_/RIHS01_df668c740482bbd48fb39d76a70dfd4bd59db1288021743503259e948f6b1a18': 'b'\x00\x01\x00\x00\x11\x00\x00\x00Hello World: 544\x00'')
>> [Subscriber] Received PUT ('0/chatter/std_msgs::msg::dds_::String_/RIHS01_df668c740482bbd48fb39d76a70dfd4bd59db1288021743503259e948f6b1a18': 'Hello World: 544')
>> [Subscriber] Received PUT ('0/chatter/std_msgs::msg::dds_::String_/RIHS01_df668c740482bbd48fb39d76a70dfd4bd59db1288021743503259e948f6b1a18': 'b'\x00\x01\x00\x00\x11\x00\x00\x00Hello World: 545\x00'')
>> [Subscriber] Received PUT ('0/chatter/std_msgs::msg::dds_::String_/RIHS01_df668c740482bbd48fb39d76a70dfd4bd59db1288021743503259e948f6b1a18': 'Hello World: 545')
```

## C++
This library appears to be actively maintained.

[eProsima/Fast-CDR](https://github.com/eProsima/Fast-CDR)

## Rust

Rust is [supported natively in Zenoh](https://zenoh.io/docs/getting-started/installation/). See the [Crate Documentation](https://docs.rs/zenoh/latest/zenoh/).

There is a Rust-native serde implementation of OMG CDR:

[jhelovuo/cdr-encoding](https://github.com/jhelovuo/cdr-encoding) / [https://crates.io/crates/cdr-encoding](https://crates.io/crates/cdr-encoding)

## Golang

Unfortunately, official Zenoh support for Go is [outdated and broken](https://github.com/eclipse-zenoh/zenoh-go). The [zenoh-c](https://github.com/eclipse-zenoh/zenoh-c) library could be used.

For serialization and deserialization, we’d have to use a c-for-go wrapper around the Fast-CDR library linked above.