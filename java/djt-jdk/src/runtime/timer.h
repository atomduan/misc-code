#ifndef DJT_RUNTIME_TIMER_H_
#define DJT_RUNTIME_TIMER_H_

#include "utilities/global_definitions.h"

// Timers for simple measurement.

class elapsedTimer {
    friend class VMStructs;
    private:
        jlong _counter;
        jlong _start_counter;
        bool  _active;
    public:
        elapsedTimer()             { _active = false; reset(); }
        elapsedTimer(jlong time, jlong timeUnitsPerSecond);
        void add(elapsedTimer t);
        void start();
        void stop();
        void reset()               { _counter = 0; }
        double seconds() const;
        jlong milliseconds() const;
        jlong ticks() const        { return _counter; }
        jlong active_ticks() const;
        bool is_active() const { return _active; }
};

// TimeStamp is used for recording when an event took place.
class TimeStamp {
    private:
        jlong _counter;
    public:
        TimeStamp()  { _counter = 0; }
        void clear() { _counter = 0; }
        // has the timestamp been updated since being created or cleared?
        bool is_updated() const { return _counter != 0; }
        // update to current elapsed time
        void update();
        // update to given elapsed time
        void update_to(jlong ticks);
        // returns seconds since updated
        // (must not be in a cleared state:  must have been previously updated)
        double seconds() const;
        jlong milliseconds() const;
        // ticks elapsed between VM start and last update
        jlong ticks() const { return _counter; }
        // ticks elapsed since last update
        jlong ticks_since_update() const;
};

class TimeHelper {
    public:
        static double counter_to_seconds(jlong counter);
        static double counter_to_millis(jlong counter);
        static jlong millis_to_counter(jlong millis);
};

#endif // DJT_RUNTIME_TIMER_H_
