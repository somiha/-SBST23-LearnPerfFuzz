# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG parent_image
FROM $parent_image

# Download and compile LearnPerfFuzz.
# Set AFL_NO_X86 to skip flaky tests.

RUN git clone https://github.com/somiha/LearnPerfFuzz.git /LearnPerfFuzz && \
    cd /LearnPerfFuzz && \
    git checkout b2ccc27e0c0fad3c75dc14f44672eee4f4a24ea2 && \
    CFLAGS= CXXFLAGS= AFL_NO_X86=1 make

# Use afl_driver.cpp from LLVM as our fuzzing library.
RUN apt-get update && \
    apt-get install wget -y && \
    wget https://raw.githubusercontent.com/llvm/llvm-project/5feb80e748924606531ba28c97fe65145c65372e/compiler-rt/lib/fuzzer/afl/afl_driver.cpp -O /LearnPerfFuzz/afl_driver.cpp && \
    clang -Wno-pointer-sign -c /LearnPerfFuzz/llvm_mode/afl-llvm-rt.o.c -I/LearnPerfFuzz && \
    clang++ -stdlib=libc++ -std=c++11 -O2 -c /LearnPerfFuzz/afl_driver.cpp && \
    ar r /libAFL.a *.o