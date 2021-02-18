#!/bin/sh
set -eu
echo "--> Installing Python."

PYTHON="${PYTHON:-3}"
if [ "${PYTHON}" != "2" -a "${PYTHON}" != "3" ]; then
    exit 0
fi

case "$(uname -r)" in
    6.8)
        PY2_PACKAGE=python-2.7.18p0
        PY3_PACKAGE=python-3.8.6
        PY3_MAJVER="3.8"
        ;;
    6.7)
        PY2_PACKAGE=python-2.7.18p0
        PY3_PACKAGE=python-3.7.7
        PY3_MAJVER="3.7"
        ;;
    6.6)
        PY2_PACKAGE=python-2.7.16p1
        PY3_PACKAGE=python-3.7.4
        PY3_MAJVER="3.7"
        ;;
    6.5)
        PY2_PACKAGE=python-2.7.16
        PY3_PACKAGE=python-3.6.8p0
        PY3_MAJVER="3.6"
        ;;
    6.4)
        PY2_PACKAGE=python-2.7.15p0
        PY3_PACKAGE=python-3.6.6p1
        PY3_MAJVER="3.6"
        ;;
    6.3)
        PY2_PACKAGE=python-2.7.14p1
        PY3_PACKAGE=python-3.6.4p0
        PY3_MAJVER="3.6"
        ;;
    6.2)
        PY2_PACKAGE=python-2.7.14
        PY3_PACKAGE=python-3.6.2
        PY3_MAJVER="3.6"
        ;;
    *)
        echo "Do not recognize OpenBSD version."
        exit 1
        ;;
esac

if [ "${PYTHON}" == "3" ]; then
    pkg_add ${PY3_PACKAGE} py3-pip
    ln -s /usr/local/bin/easy_install-${PY3_MAJVER} /usr/local/bin/easy_install
    ln -s /usr/local/bin/pip${PY3_MAJVER} /usr/local/bin/pip3
    ln -s /usr/local/bin/pyvenv-${PY3_MAJVER} /usr/local/bin/pyvenv
else
    pkg_add ${PY2_PACKAGE} py-pip
    ln -s /usr/local/bin/easy_install-2.7 /usr/local/bin/easy_install
    ln -s /usr/local/bin/pip2.7 /usr/local/bin/pip
fi
