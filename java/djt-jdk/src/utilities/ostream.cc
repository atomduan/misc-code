#include "utilities/ostream.h"

OutputStream* tty;

OutputStream::OutputStream(int width) {
    _width             = width;
    _position        = 0;
    _newlines        = 0;
    _precount        = 0;
    _indentation = 0;
    _scratch         = NULL;
    _scratch_len = 0;
}

void OutputStream::update_position(const char* s, size_t len) {
    for (size_t i = 0; i < len; i++) {
        char ch = s[i];
        if (ch == '\n') {
            _newlines += 1;
            _precount += _position + 1;
            _position = 0;
        } else if (ch == '\t') {
            int tw = 8 - (_position & 7);
            _position += tw;
            _precount -= tw-1;
        } else {
            _position += 1;
        }
    }
}

FileStream::FileStream(const char* file_name) {
    _file = fopen(file_name, "w");
    if (_file != NULL) {
        _need_close = true;
    } else {
        _need_close = false;
    }
}

FileStream::FileStream(const char* file_name, const char* opentype) {
    _file = fopen(file_name, opentype);
    if (_file != NULL) {
        _need_close = true;
    } else {
        _need_close = false;
    }
}

FileStream::~FileStream() {
    if (_file != NULL) {
        if (_need_close) fclose(_file);
        _file            = NULL;
    }
}

void FileStream::flush() {
    fflush(_file);
}

void FileStream::write(const char* s, size_t len) {
    if (_file != NULL)    {
        fwrite(s, 1, len, _file);
    }
    update_position(s, len);
}

long FileStream::fileSize() {
    long size = -1;
    if (_file != NULL) {
        long pos = ::ftell(_file);
        if (pos < 0) return pos;
        if (::fseek(_file, 0, SEEK_END) == 0) {
            size = ::ftell(_file);
        }
        ::fseek(_file, pos, SEEK_SET);
    }
    return size;
}

char* FileStream::readln(char *data, int count ) {
    char * ret = ::fgets(data, count, _file);
    data[::strlen(data)-1] = '\0';
    return ret;
}
