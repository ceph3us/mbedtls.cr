# mbedtls.cr

Crystal language bindings to the [mbed TLS](https://tls.mbed.org/) lightweight TLS and
cryptography library, based on the [openssl.cr bindings](https://github.com/datanoise/openssl.cr).

In development, not yet stable.

Implemented:

* [x] Message digests (hashing)
* [ ] HMAC authenticated digests
* [ ] CSPRNG (cryptographic random numbers)
* [ ] Symmetric encryption
* [ ] Asymmetric encryption
* [ ] X509 certificate utilities
* [ ] TLS connection wrapping

## Disclaimer

Cryptography is hard. This library is not thoroughly tested; it might have flaws in it's bindings.
As per the [terms of the license](https://github.com/ceph3us/mbedtls.cr), by using this you
understand this is at your own risk.

## Installation

You must install mbed TLS for your platform.

I test mbedtls.cr with mbed TLS 2.4.2. Other versions could work, but they are not tested.
You can file a Pull Request on this Readme if you succeed in getting it to work with other
versions. It won't work with mbed TLS versions before 2.0, or PolarSSL.

*Please note:* Versions of mbed TLS before 2.1 are under the GPL2 licence, and your
distribution may bundle the GPL2 licensed version. If you need to redistribute the mbed
TLS library with your project, consider downloading and building the Apache licensed version.
The project is the same, it has Apache license headers and files replacing the GPL ones.

### Installing mbed TLS

macOS:
```shell
brew install mbedtls
```

Ubuntu/Debian
```shell
brew install libmbedtls libmbedtls-dev
```

Fedora/CentOS
```shell
yum install mbedtls mbedtls-devel
```

*Note:* You need Fedora 22+ for a 2.x mbed version.
CentOS and RHEL 6/7 users will need to use [EPEL](https://fedoraproject.org/wiki/EPEL) for
suitable `mbedtls` packages.

Arch Linux
```shell
pacman -S mbedtls
```
[Never use pacman -Sy when installing packages!](https://wiki.archlinux.org/index.php/System_maintenance#Partial_upgrades_are_unsupported)

### Using in your project or package

Add this to your application's `shard.yml`:

```yaml
dependencies:
  mbedtls:
    github: ceph3us/mbedtls.cr
```

## Usage

Full usage information is available in the [documentation](http://ceph3.us/mbedtls.cr).

### Message Digests (hashing)

```crystal
require "mbedtls"

hash = MbedTLS::Digest::SHA256.new

# You can hash a whole string...
hash << "Hello, world"
puts %(The SHA256 hash of "Hello, world" is #{hash})

hash.reset

# ...or some concatenated strings...
hash << "Hello, " << "world"
puts %(The SHA256 hash of "Hello, world" is #{hash})

hash.reset

# ...or even a file!
hash.file("hello.txt")
puts "The SHA256 hash of the file hello.txt is #{hash}"
```

## Development

If you have any suggestions or issues with the project, I'd be happy to listen to your concerns.
Post [a GitHub issue](https://github.com/ceph3us/mbedtls.cr/issues/new) so we can discuss them.

## Contributing

mbedtls.cr uses the [GitLab flow](https://docs.gitlab.com/ee/workflow/gitlab_flow.html) for repositories. To contribute:

1. [Fork it](https://github.com/ceph3us/mbedtls.cr/fork)!
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. [Submit a new Pull Request](https://github.com/ceph3us/mbedtls.cr/compare) with your changes.

If you do this a lot, consider the awesome [Git Town](http://www.git-town.com/) which has lots of handy
shortcuts for the GitLab flow and other Git workflows.

## Contributors

- [ceph3us](https://github.com/ceph3us) Michael Holmes - creator, maintainer
