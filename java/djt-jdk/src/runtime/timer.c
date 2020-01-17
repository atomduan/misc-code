#include "runtime/timer.h"
#include "runtime/os.h"
#include "utilities/global_definitions.h"

jlong os::elapsed_frequency() {
    return NANOSECS_PER_SEC; // nanosecond resolution
}

double TimeHelper::counter_to_seconds(jlong counter) {
    double freq = (double) os::elapsed_frequency();
    return counter / freq;
}

double TimeHelper::counter_to_millis(jlong counter) {
    return counter_to_seconds(counter) * 1000.0;
}

jlong TimeHelper::millis_to_counter(jlong millis) {
    jlong freq = os::elapsed_frequency() / MILLIUNITS;
    return millis * freq;
}

elapsedTimer::elapsedTimer(jlong time, jlong timeUnitsPerSecond) {
    _active = false;
    jlong osTimeUnitsPerSecond = os::elapsed_frequency();
    while (osTimeUnitsPerSecond < timeUnitsPerSecond) {
        timeUnitsPerSecond /= 1000;
        time *= 1000;
    }
    while (osTimeUnitsPerSecond > timeUnitsPerSecond) {
        timeUnitsPerSecond *= 1000;
        time /= 1000;
    }
    _counter = time;
}

void elapsedTimer::add(elapsedTimer t) {
    _counter += t._counter;
}

void elapsedTimer::start() {
    if (!_active) {
        _active = true;
        _start_counter = os::elapsed_counter();
    }
}

void elapsedTimer::stop() {
    if (_active) {
        _counter += os::elapsed_counter() - _start_counter;
        _active = false;
    }
}

double elapsedTimer::seconds() const {
 return TimeHelper::counter_to_seconds(_counter);
}

jlong elapsedTimer::milliseconds() const {
    return (jlong)TimeHelper::counter_to_millis(_counter);
}

jlong elapsedTimer::active_ticks() const {
    if (!_active) {
        return ticks();
    }
    jlong counter = _counter + os::elapsed_counter() - _start_counter;
    return counter;
}

void TimeStamp::update_to(jlong ticks) {
    _counter = ticks;
    if (_counter == 0) _counter = 1;
}

void TimeStamp::update() {
    update_to(os::elapsed_counter());
}

double TimeStamp::seconds() const {
    jlong new_count = os::elapsed_counter();
    return TimeHelper::counter_to_seconds(new_count - _counter);
}

jlong TimeStamp::milliseconds() const {
    jlong new_count = os::elapsed_counter();
    return (jlong)TimeHelper::counter_to_millis(new_count - _counter);
}

jlong TimeStamp::ticks_since_update() const {
    return os::elapsed_counter() - _counter;
}
