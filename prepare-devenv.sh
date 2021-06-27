# shellcheck disable=SC1091,SC2155

# SOURCE THIS FILE
# . prepare-devenv blue|s|x

if [ $# -ne 1 ]; then
    echo "Possible options: blue, s or x"
    return
elif [[ $1 == "-h" ]]; then
    echo "Possible options: blue, s or x"
    return
elif [[ $1 != "blue" ]] && [[ $1 != "s" ]] && [[ $1 != "x" ]]; then
    echo "Possible options: blue, s or x"
    return
fi

if [[ $(dpkg-query -s python3-venv 2>&1) == *'is not installed'* ]]; then
    printf "\nPackage python3-venv is missing.\nOn Debian-like distros, run:\n\napt install python3-venv\n\n"
    return
fi

if [[ $(cat /etc/udev/rules.d/20-hw1.rules) == *'ATTRS{idVendor}=="2c97", ATTRS{idProduct}=="0004"'* ]]; then
    printf "\nMissing udev rules. Please refer to https://support.ledger.com/hc/en-us/articles/115005165269-Fix-connection-issues\n\n"
    return
fi


if [ ! -d dev-env ]; then
    mkdir dev-env
    mkdir dev-env/SDK
    mkdir dev-env/CC
    mkdir dev-env/CC/others
    mkdir dev-env/CC/nanox

    wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2 -O gcc-arm-none-eabi-linux.tar.bz2
    tar xf gcc-arm-none-eabi-linux.tar.bz2 -C gcc-arm-none-eabi-linux
    rm gcc-arm-none-eabi-linux.tar.bz2
    cp -r gcc-arm-none-eabi-* dev-env/CC/nanox/gcc-arm-none-eabi-linux
    mv gcc-arm-none-eabi-* dev-env/CC/others/gcc-arm-none-eabi-linux

    wget https://releases.llvm.org/9.0.0/clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz -O clang+llvm.tar.xz
    tar xf clang+llvm.tar.xz
    rm clang+llvm.tar.xz
    mv clang+llvm* dev-env/CC/nanox/clang-arm-fropi
    cp -r dev-env/CC/nanox/clang-arm-fropi dev-env/CC/others/.

    #wget https://github.com/LedgerHQ/blue-secure-sdk/archive/blue-r21.1.tar.gz -O blue-secure-sdk.tar.gz
    #tar xf blue-secure-sdk.tar.gz
    #rm blue-secure-sdk.tar.gz
    #mv blue-secure-sdk* dev-env/SDK/blue-secure-sdk

    wget https://github.com/LedgerHQ/nanos-secure-sdk/archive/refs/tags/2.0.0-1.tar.gz -O nanos-secure-sdk.tar.gz
    tar xf nanos-secure-sdk.tar.gz
    rm nanos-secure-sdk.tar.gz
    mv nanos-secure-sdk* dev-env/SDK/nanos-secure-sdk

    python3 -m venv dev-env/ledger_py3
    source dev-env/ledger_py3/bin/activate
    pip install wheel
    pip install ledgerblue
fi


source dev-env/ledger_py3/bin/activate

if [[ $1 == "blue" ]]; then
    export BOLOS_SDK=$(pwd)/dev-env/SDK/blue-secure-sdk
    export BOLOS_ENV=$(pwd)/dev-env/CC/others
elif [[ $1 == "s" ]]; then
    export BOLOS_SDK=$(pwd)/dev-env/SDK/nanos-secure-sdk
    export BOLOS_ENV=$(pwd)/dev-env/CC/others
elif [[ $1 == "x" ]]; then
    export BOLOS_SDK=$(pwd)/dev-env/SDK/nanox-secure-sdk
    export BOLOS_ENV=$(pwd)/dev-env/CC/nanox
fi
