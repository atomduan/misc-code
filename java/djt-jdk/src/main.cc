#include <iostream>

#include "memory/allocation.h"
#include "utilities/breakpoint.h"
#include "utilities/macros.h"
#include "utilities/global_definitions.h"
#include "utilities/ostream.h"

int main(int argc, char** argv) {
    std::cout << "Have " << argc << " arguments:" << std::endl;
    for (int i = 0; i < argc; ++i) {
        std::cout << argv[i] << std::endl;
    }
    const char* file_name = "/tmp/foo.txt";
    tty = new(ResourceObj::C_HEAP, mtInternal) FileStream(file_name);
}
