#include "timer.h"

namespace utils {

void sleep(double t){
  timespec req;
  req.tv_sec = (int) t; 
  req.tv_nsec = (int64_t)(1e9 * (t - (int64_t)t)); 
  nanosleep(&req, NULL); 
}

int64_t time_now(){
  timespec ts; 
  clock_gettime(CLOCK_REALTIME, &ts);
  int64_t t = ts.tv_sec;
  t = t * 1000000000 + ts.tv_nsec;
  return t; 
}
}

