# Sandstorm - Personal Cloud Sandbox
# Copyright (c) 2014 Sandstorm Development Group, Inc. and contributors
# All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

@0xdf9bc20172856a3a;
# This file contains schemas relevant to the Sandstorm package format.  See also the `spk` tool.

$import "/capnp/c++.capnp".namespace("sandstorm::spk");

using Util = import "util.capnp";
using Grain = import "grain.capnp";

struct PackageDefinition {
  id @0 :Text;
  # The app's ID string. This is actually an encoding of the app's public key generated by the spk
  # tool, and looks something like "h37dm17aa89yrd8zuqpdn36p6zntumtv08fjpu8a8zrte7q1cn60".
  #
  # Normally, `spk init` will fill this in for you. You can use `spk keygen` to generate a new ID
  # if needed. The private key corresponding to each ID is stored in a keyring outside your project
  # directory; see `spk help` for more on this.
  #
  # Note that you can specify an alternative ID to `spk pack` with the `-i` flag. This makes sense
  # when you are doing an unofficial build of an app and don't want to use (or don't have access
  # to) the app's real private key.

  manifest @1 :Manifest;
  # Manifest to write as the package's `sandstorm_manifest`.  If null, then `sandstorm-manifest`
  # should appear in the file list.

  sourceMap @2 :SourceMap;
  # Indicates where to search for file to include in the package.

  fileList @3 :Text;
  # Name of a file which itself contains a list of files, one per line, that should be included
  # in the package. Each file should be specified according to its location in the package; the
  # source file will be found by mapping this through `sourceMap`. Each name should be canonical
  # (no ".", "..", or consecutive slashes) and should NOT start with '/'.
  #
  # The file list is automatically generated by `spk dev` based on watching what files are opened
  # by the actual running server. On subsequent runs, new files will be added, but files will never
  # be removed from the list. To reset the list, simply delete it and run `spk dev` again.

  alwaysInclude @4 :List(Text);
  # Files and directories that should always be included in the package whether or not they are
  # in the file named by `fileList`. If you name a directory here, its entire contents will be
  # included recursively (this is not the case in `fileList`). Use this list to name files that
  # wouldn't automatically be included, because for whatever reason the server does not actually
  # open them when running in dev mode. This could include runtime dependencies that are too
  # difficult to test fully, or perhaps a readme file or copyright notice that you want people to
  # see if they unpack your package manually.

  bridgeConfig @5 :BridgeConfig;
  # Configuration variables for apps that use sandstorm-http-bridge.
}

struct Manifest {
  # This manifest file defines an application.  The file `sandstorm-manifest` at the root of the
  # application's `.spk` package contains a serialized (binary) instance of `Manifest`.
  #
  # TODO(soon):  Maybe this should be renamed.  A "manifest" is a list of contents, but this
  #   structure doesn't contain a list at all; it contains information on how to use the contents.

  appTitle @7 :Util.LocalizedText;
  # The name of this app as it should be displayed to the user.

  appVersion @4 :UInt32;
  # Among app packages with the same app ID (i.e. the same `publicKey`), `version` is used to
  # decide which packages represent newer vs. older versions of the app.  The sole purpose of this
  # number is to decide whether one package is newer than another; it is not normally displayed to
  # the user.  This number need not have anything to do with the "marketing version" of your app.

  minUpgradableAppVersion @5 :UInt32;
  # The minimum version of the app which can be safely replaced by this app package without data
  # loss.  This might be non-zero if the app's data store format changed drastically in the past
  # and the app is no longer able to read the old format.

  appMarketingVersion @6 :Util.LocalizedText;
  # Human-readable presentation of the app version, e.g. "2.9.17".  This will be displayed to the
  # user to distinguish versions.  It _should_ match the way you identify versions of your app to
  # users in documentation and marketing.

  minApiVersion @0 :UInt32;
  maxApiVersion @1 :UInt32;
  # Min and max API versions against which this app is known to work.  `minApiVersion` primarily
  # exists to warn the user if their instance is too old.  If the sandstorm instance is newer than
  # `maxApiVersion`, it may engage backwards-compatibility hacks and hide features introduced in
  # newer versions.

  struct Command {
    # Description of a command to execute.
    #
    # Note that commands specified this way are NOT interpreted by a shell.  If you want shell
    # expansion, you must include a shell binary in your app and invoke it to interpret the
    # command.

    argv @1 :List(Text);
    # Argument list, with the program name as argv[0].

    environ @2 :List(Util.KeyValue);
    # Environment variables to set.  The environment will be completely empty other than what you
    # define here.

    deprecatedExecutablePath @0 :Text;
    # (Obsolete) If specified, will be inserted at the beginning of argv. This is now redundant
    # because you should just specify the program as argv[0]. To be clear, this does not and did
    # never provide a way to make argv[0] contain something other than the executable name, as
    # you can technically do with the `exec` system call.
  }

  struct Action {
    input :union {
      none @0 :Void;
      # This action creates a new grain with no input.

      capability @1 :List(Grain.PowerboxDescriptor);
      # This action creates a new grain from a powerbox offer. When a capability matching the query
      # is offered to the user (e.g. by another application calling SessionContext.offer()), this
      # action will be listed as one of the things the user can do with it.
      #
      # On startup, the platform will call create the first session with
      # `UiView.newOfferSession()`.
    }

    command @2 :Command;
    # Command to execute (in a newly-allocated grain) to run this action.

    title @3 :Util.LocalizedText;
    # Title of this action, to display in the action selector.

    description @4 :Util.LocalizedText;
    # Description of this action, suitable for help text.
  }

  actions @2 :List(Action);
  # Actions which this grain offers.

  continueCommand @3 :Command;
  # Command to run to restart an already-created grain.
}

struct SourceMap {
  # Defines where to find files that need to be included in a package.  This is usually combined
  # with a list of files that the package is expected to contain in order to compile a package.
  # The list of files may come from using "spk dev" to

  searchPath @0 :List(Mapping);
  # List of directories to map into the package.

  struct Mapping {
    # Describes a directory to be mapped into the package.

    packagePath @0 :Text;
    # Path where this directory should be mapped into the package.  Must be a canonical file name
    # (no "." nor "..") and must not start with '/'. Omit to map to the package root directory.

    sourcePath @1 :Text;
    # Path on the local system where this directory may be found.  Relative paths are interpreted
    # relative to the location of the package definition file.

    hidePaths @2 :List(Text);
    # Names of files or subdirectories within the directory which should be hidden when mapping
    # this path into the spk.  Use only canonical paths here -- i.e. do not use ".", "..", or
    # multiple consecutive slashes.  Do not use a leading slash.
  }
}

struct BridgeConfig {
  # Configuration variables specific to apps that are using sandstorm-http-bridge. This includes
  # things that need to be communicated to the bridge process before the app starts up, such as
  # permissions.

  viewInfo @0 :Grain.UiView.ViewInfo;
  # What to return from the UiView's getViewInfo(). This structure defines, among other things, the
  # list of sharable permissions and roles that apply to this app. See grain.capnp for more details.
  #
  # When a request comes in from the user, sandstorm-http-bridge will set the
  # X-Sandstorm-Permissions header to a comma-delimited list of permission names corresponding to
  # the user's permissions.

  apiPath @1 :Text;
  # This variable's purpose is two-fold:
  # First, if it's set to anything non-empty, it will enable ApiSessions in sandstorm-http-bridge.
  # This means calling newSession with an ApiSession type id will return an ApiSession correctly.
  # Second, as the name implies, this specifies the path to the API in an app. For example, if
  # your API endpoints always begin with /v1/api/, then you would provide that path. This path will
  # always be prepended for you, and clients accessing the API will not have to provide it. This
  # also has the effect of limiting your clients to only accessing endpoints under that path you
  # provide. It should always end in a trailing '/'.
  # "/" is a valid value, and will give clients access to all paths.
}

# ==============================================================================
# Below this point is not interesting to app developers.
#
# TODO(cleanup): Maybe move elsewhere?

struct KeyFile {
  # A public/private key pair, as generated by libsodium's crypto_sign_keypair.
  #
  # The keyring maintained by the spk tool contains a sequence of these.
  #
  # TODO(someday):  Integrate with desktop environment's keychain for more secure storage.

  publicKey @0 :Data;
  privateKey @1 :Data;
}

const magicNumber :Data = "\x8f\xc6\xcd\xef\x45\x1a\xea\x96";
# A sandstorm package is a file composed of two messages: a `Signature` and an `Archive`.
# Additionally, the whole file is XZ-compressed on top of that, and the XZ data is prefixed with
# `magicNumber`.  (If a future version of the package format breaks compatibility, the magic number
# will change.)

struct Signature {
  # Contains a cryptographic signature of the `Archive` part of the package, along with the public
  # key used to verify that signature.  The public key itself is the application ID, thus all
  # packages signed with the same key will be considered to be different versions of the same app.

  publicKey @0 :Data;
  # A libsodium crypto_sign public key.
  #
  # libsodium signing public keys are 32 bytes.  The application's ID is simply a textual
  # representation of this key.

  signature @1 :Data;
  # libsodium crypto_sign signature of the crypto_hash of the `Archive` part of the package
  # (i.e. the package file minus the header).
}

struct Archive {
  # A tree of files.  Used to represent the package contents.

  files @0 :List(File);

  struct File {
    name @0 :Text;
    # Name of the file.
    #
    # Must not contain forward slashes nor NUL characters.  Must not be "." nor "..".  Must not
    # be the same as any other file in the directory.

    lastModificationTimeNs @5 :Int64;
    # Modification timestamp to apply to the file after unpack. Measured in nanoseconds.

    union {
      regular @1 :Data;
      # Content of a regular file.

      executable @2 :Data;
      # Content of an executable.

      symlink @3 :Text;
      # Symbolic link path.  The link will be interpreted in the context of the sandbox, where the
      # archive itself mounted as the root directory.

      directory @4 :List(File);
      # A subdirectory containing a list of files.
    }
  }
}
using Go = import "/zombiezen.com/go/capnproto2/go.capnp";
$Go.package("spk");
$Go.import("zenhack.net/go/sandstorm/capnp/sandstorm/spk");
