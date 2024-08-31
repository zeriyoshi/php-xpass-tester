#!/bin/sh -eu

cd "/php-xpass"
  phpize
  ./configure
  TEST_PHP_ARGS="-q --show-diff" make -j"$(nproc)" test
cd -
