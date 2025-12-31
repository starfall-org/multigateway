#!/bin/bash

# Script để thay thế tất cả imports từ package riêng sang package chính

echo "Đang thay thế imports cho package:profiles..."
find lib -type f -name "*.dart" -exec sed -i "s|import 'package:profiles/profiles.dart';|import 'package:metalore/core/profile/profile.dart';|g" {} \;

echo "Đang thay thế imports cho package:speech..."
find lib -type f -name "*.dart" -exec sed -i "s|import 'package:speech/speech.dart';|import 'package:metalore/core/speech/speech.dart';|g" {} \;

echo "Hoàn thành!"
