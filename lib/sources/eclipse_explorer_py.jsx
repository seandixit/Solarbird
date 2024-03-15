// Goal: print out local circumstances given the following observer constants/parameters:

// Observer constants:
// (0) North Latitude (radians): 39° 46' 00" N
// (1) West Longitude (radians): 86° 09' 00" W
// (2) Altitude (metres): 241.4m
// (3) West time zone (hours): 05:00 W
// (4) rho sin O': ????
// (5) rho cos O': ????
// (6) index into the elements array for the eclipse in question

// functions changed: readform, gettime, getalt, getazi, getmagnitude, getcoverage, calculatefor, settimeperiod

var obsvconst = new Array();

var month = new Array("Jan","Feb","Mar","Apr","May","Jun","Jul",
                      "Aug","Sep","Oct","Nov","Dec");

var c1 = new Array();
var c2 = new Array();
var mid = new Array();
var c3 = new Array();
var c4 = new Array();


var currenttimeperiod = "";
var loadedtimeperiods = new Array();

// Populate the circumstances array with the time-only dependent circumstances (x, y, d, m, ...)
// assumes elements is filled
// calculates circumstances
function timedependent(elements, circumstances) {
    var type, index, t, ans;
  
    t = circumstances[1]
    index = obsvconst[6]
    // Calculate x
    ans = elements[9+index] * t + elements[8+index]
    ans = ans * t + elements[7+index]
    ans = ans * t + elements[6+index]
    circumstances[2] = ans
    // Calculate dx
    ans = 3.0 * elements[9+index] * t + 2.0 * elements[8+index]
    ans = ans * t + elements[7+index]
    circumstances[10] = ans
    // Calculate y
    ans = elements[13+index] * t + elements[12+index]
    ans = ans * t + elements[11+index]
    ans = ans * t + elements[10+index]
    circumstances[3] = ans
    // Calculate dy
    ans = 3.0 * elements[13+index] * t + 2.0 * elements[12+index]
    ans = ans * t + elements[11+index]
    circumstances[11] = ans
    // Calculate d
    ans = elements[16+index] * t + elements[15+index]
    ans = ans * t + elements[14+index]
    ans = ans * Math.PI / 180.0
    circumstances[4] = ans
    // sin d and cos d
    circumstances[5] = Math.sin(ans)
    circumstances[6] = Math.cos(ans)
    // Calculate dd
    ans = 2.0 * elements[16+index] * t + elements[15+index]
    ans = ans * Math.PI / 180.0
    circumstances[12] = ans
    // Calculate m
    ans = elements[19+index] * t + elements[18+index]
    ans = ans * t + elements[17+index]
    if (ans >= 360.0) {
      ans = ans - 360.0
    }
    ans = ans * Math.PI / 180.0
    circumstances[7] = ans
    // Calculate dm
    ans = 2.0 * elements[19+index] * t + elements[18+index]
    ans = ans * Math.PI / 180.0
    circumstances[13] = ans
    // Calculate l1 and dl1
    type = circumstances[0]
    if ((type == -2) || (type == 0) || (type == 2)) {
      ans = elements[22+index] * t + elements[21+index]
      ans = ans * t + elements[20+index]
      circumstances[8] = ans
      circumstances[14] = 2.0 * elements[22+index] * t + elements[21+index]
    }
    // Calculate l2 and dl2
    if ((type == -1) || (type == 0) || (type == 1)) {
      ans = elements[25+index] * t + elements[24+index]
      ans = ans * t + elements[23+index]
      circumstances[9] = ans
      circumstances[15] = 2.0 * elements[25+index] * t + elements[24+index]
    }
    return circumstances
  }

// Populate the circumstances array with the time and location dependent circumstances
function timelocdependent(elements,circumstances) {
    var ans, index, type
  
    timedependent(elements,circumstances)
    index = obsvconst[6]
    // Calculate h, sin h, cos h
    circumstances[16] = circumstances[7] - obsvconst[1] - (elements[index+5] / 13713.44)
    circumstances[17] = Math.sin(circumstances[16])
    circumstances[18] = Math.cos(circumstances[16])
    // Calculate xi
    circumstances[19] = obsvconst[5] * circumstances[17]
    // Calculate eta
    circumstances[20] = obsvconst[4] * circumstances[6] - obsvconst[5] * circumstances[18] * circumstances[5]
    // Calculate zeta
    circumstances[21] = obsvconst[4] * circumstances[5] + obsvconst[5] * circumstances[18] * circumstances[6]
    // Calculate dxi
    circumstances[22] = circumstances[13] * obsvconst[5] * circumstances[18]
    // Calculate deta
    circumstances[23] = circumstances[13] * circumstances[19] * circumstances[5] - circumstances[21] * circumstances[12]
    // Calculate u
    circumstances[24] = circumstances[2] - circumstances[19]
    // Calculate v
    circumstances[25] = circumstances[3] - circumstances[20]
    // Calculate a
    circumstances[26] = circumstances[10] - circumstances[22]
    // Calculate b
    circumstances[27] = circumstances[11] - circumstances[23]
    // Calculate l1'
    type = circumstances[0]
    if ((type == -2) || (type == 0) || (type == 2)) {
      circumstances[28] = circumstances[8] - circumstances[21] * elements[26+index]
    }
    // Calculate l2'
    if ((type == -1) || (type == 0) || (type == 1)) {
      circumstances[29] = circumstances[9] - circumstances[21] * elements[27+index]
    }
    // Calculate n^2
    circumstances[30] = circumstances[26] * circumstances[26] + circumstances[27] * circumstances[27]
    return circumstances
  }

// Iterate on C1 or C4
function c1c4iterate(elements,circumstances) {
    var sign, iter, tmp, n
  
    timelocdependent(elements,circumstances)
    if (circumstances[0] < 0) {
      sign=-1.0
    } else {
      sign=1.0
    }
    tmp=1.0
    iter=0
    while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
      n = Math.sqrt(circumstances[30])
      tmp = circumstances[26] * circumstances[25] - circumstances[24] * circumstances[27]
      tmp = tmp / n / circumstances[28]
      tmp = sign * Math.sqrt(1.0 - tmp * tmp) * circumstances[28] / n
      tmp = (circumstances[24] * circumstances[26] + circumstances[25] * circumstances[27]) / circumstances[30] - tmp
      circumstances[1] = circumstances[1] - tmp
      timelocdependent(elements,circumstances)
      iter++
    }
    return circumstances
  }

// Get C1 and C4 data
//   Entry conditions -
//   1. The mid array must be populated
//   2. The magnitude at mid eclipse must be > 0.0
function getc1c4(elements) {
    var tmp, n
  
    n = Math.sqrt(mid[30])
    tmp = mid[26] * mid[25] - mid[24] * mid[27]
    tmp = tmp / n / mid[28]
    tmp = Math.sqrt(1.0 - tmp * tmp) * mid[28] / n
    c1[0] = -2
    c4[0] = 2
    c1[1] = mid[1] - tmp
    c4[1] = mid[1] + tmp
    c1c4iterate(elements,c1)
    c1c4iterate(elements,c4)
  }

// Iterate on C2 or C3
function c2c3iterate(elements,circumstances) {
    var sign, iter, tmp, n
  
    timelocdependent(elements,circumstances)
    if (circumstances[0] < 0) {
      sign=-1.0
    } else {
      sign=1.0
    }
    if (mid[29] < 0.0) {
      sign = -sign
    }
    tmp=1.0
    iter=0
    while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
      n = Math.sqrt(circumstances[30])
      tmp = circumstances[26] * circumstances[25] - circumstances[24] * circumstances[27]
      tmp = tmp / n / circumstances[29]
      tmp = sign * Math.sqrt(1.0 - tmp * tmp) * circumstances[29] / n
      tmp = (circumstances[24] * circumstances[26] + circumstances[25] * circumstances[27]) / circumstances[30] - tmp
      circumstances[1] = circumstances[1] - tmp
      timelocdependent(elements,circumstances)
      iter++
    }
    return circumstances
  }
  
  //
  // Get C2 and C3 data
  //   Entry conditions -
  //   1. The mid array must be populated
  //   2. There must be either a total or annular eclipse at the location!
  function getc2c3(elements) {
    var tmp, n
  
    n = Math.sqrt(mid[30])
    tmp = mid[26] * mid[25] - mid[24] * mid[27]
    tmp = tmp / n / mid[29]
    tmp = Math.sqrt(1.0 - tmp * tmp) * mid[29] / n
    c2[0] = -1
    c3[0] = 1
    if (mid[29] < 0.0) {
      c2[1] = mid[1] + tmp
      c3[1] = mid[1] - tmp
    } else {
      c2[1] = mid[1] - tmp
      c3[1] = mid[1] + tmp
    }
    c2c3iterate(elements,c2)
    c2c3iterate(elements,c3)
  }

// Get the observational circumstances
function observational(circumstances) {
    var contacttype, coslat, sinlat
  
    // We are looking at an "external" contact UNLESS this is a total eclipse AND we are looking at
    // c2 or c3, in which case it is an INTERNAL contact! Note that if we are looking at mid eclipse,
    // then we may not have determined the type of eclipse (mid[39]) just yet!
    if (circumstances[0] == 0) {
      contacttype = 1.0
    } else {
      if ((mid[39] == 3) && ((circumstances[0] == -1) || (circumstances[0] == 1))) {
        contacttype = -1.0
      } else {
        contacttype = 1.0
      }
    }
    // Calculate p
    circumstances[31] = Math.atan2(contacttype*circumstances[24], contacttype*circumstances[25])
    // Calculate alt
    sinlat = Math.sin(obsvconst[0])
    coslat = Math.cos(obsvconst[0])
    circumstances[32] = Math.asin(circumstances[5] * sinlat + circumstances[6] * coslat * circumstances[18])
    // Calculate q
    circumstances[33] = Math.asin(coslat * circumstances[17] / Math.cos(circumstances[32]))
    if (circumstances[20] < 0.0) {
      circumstances[33] = Math.PI - circumstances[33]
    }
    // Calculate v
    circumstances[34] = circumstances[31] - circumstances[33]
    // Calculate azi
    circumstances[35] = Math.atan2(-1.0*circumstances[17]*circumstances[6], circumstances[5]*coslat - circumstances[18]*sinlat*circumstances[6])
    // Calculate visibility
    if (circumstances[32] > -0.00524) {
      circumstances[40] = 0
    } else {
      circumstances[40] = 1
    }
  }

// Get the observational circumstances for mid eclipse
function midobservational() {
    observational(mid)
    // Calculate m, magnitude and moon/sun
    mid[36] = Math.sqrt(mid[24]*mid[24] + mid[25]*mid[25])
    mid[37] = (mid[28] - mid[36]) / (mid[28] + mid[29])
    mid[38] = (mid[28] - mid[29]) / (mid[28] + mid[29])
  }
  
  //
  // Calculate mid eclipse
  function getmid(elements) {
    var iter, tmp
  
    mid[0] = 0
    mid[1] = 0.0
    iter = 0
    tmp = 1.0
    timelocdependent(elements,mid)
    while (((tmp > 0.000001) || (tmp < -0.000001)) && (iter < 50)) {
      tmp = (mid[24] * mid[26] + mid[25] * mid[27]) / mid[30]
      mid[1] = mid[1] - tmp
      iter++
      timelocdependent(elements,mid)
    }
  }

// Calculate the time of sunrise or sunset
function getsunriset(elements,circumstances,riset) {
    var h0, diff, iter
  
    diff = 1.0
    iter = 0
    while ((diff > 0.00001) || (diff < -0.00001)) {
      iter++
      if (iter == 4) return
      h0 = Math.acos((Math.sin(-0.00524) - Math.sin(obsvconst[0]) * circumstances[5])/Math.cos(obsvconst[0])/circumstances[6])
      diff = (riset * h0 - circumstances[16])/circumstances[13];
      while (diff >= 12.0) diff -= 24.0;
      while (diff <= -12.0) diff += 24.0;
      circumstances[1] += diff
      timelocdependent(elements,circumstances)
    }
  }

  // Copy a set of circumstances
  function copycircumstances(circumstancesfrom, circumstancesto) {
    var i;
  
    for (i = 1 ; i < 41 ; i++) {
      circumstancesto[i] = circumstancesfrom[i];
    }
  }

// Calculate the time of sunrise
function getsunrise(elements,circumstances) {
  getsunriset(elements,circumstances,-1.0)
}

//
// Calculate the time of sunset
function getsunset(elements,circumstances) {
  getsunriset(elements,circumstances,1.0)
}

// Populate the c1, c2, mid, c3 and c4 arrays
function getall(elements) {
    var pattern
  
    getmid(elements)
    midobservational()
    if (mid[37] > 0.0) {
      getc1c4(elements)
      if ((mid[36] < mid[29]) || (mid[36] < -mid[29])) {
        getc2c3(elements)
        if (mid[29] < 0.0) {
          mid[39] = 3 // Total eclipse
        } else {
          mid[39] = 2 // Annular eclipse
        }
        observational(c1)
        observational(c2)
        observational(c3)
        observational(c4)
        c2[36] = 999.9
        c3[36] = 999.9
        // Calculate how much of the eclipse is above the horizon
        pattern = 0
        if (c1[40] == 0) { pattern += 10000 }
        if (c2[40] == 0) { pattern += 1000 }
        if (mid[40] == 0) { pattern += 100 }
        if (c3[40] == 0) { pattern += 10 }
        if (c4[40] == 0) { pattern += 1 }
        // Now, time to make sure that all my observational[39] and observational[40] are OK
        if (pattern == 11110) {
          getsunset(elements,c4)
          observational(c4)
          c4[40] = 3
        } else if (pattern == 11100) {
          getsunset(elements,c3)
          observational(c3)
          c3[40] = 3
          copycircumstances(c3, c4);
        } else if (pattern == 11000) {
          c3[40] = 4
          getsunset(elements,mid)
          midobservational()
          mid[40] = 3
          copycircumstances(mid, c4)
        } else if (pattern == 10000) {
          mid[39] = 1
          getsunset(elements,mid)
          midobservational()
          mid[40] = 3
          copycircumstances(mid, c4)
        } else if (pattern == 1111) {
          getsunrise(elements,c1)
          observational(c1)
          c1[40] = 2
        } else if (pattern == 111) {
          getsunrise(elements,c2)
          observational(c2)
          c2[40] = 2
          copycircumstances(c2, c1)
        } else if (pattern == 11) {
          c2[40] = 4
          getsunrise(elements,mid)
          midobservational()
          mid[40] = 2
          copycircumstances(mid, c1)
        } else if (pattern == 1) {
          mid[39] = 1
          getsunrise(elements,mid)
          midobservational()
          mid[40] = 2
          copycircumstances(mid, c1)
        } else if (pattern == 0) {
          mid[39] = 0
        }
        // There are other patterns, but those are the only ones we're covering!
     } else {
        mid[39] = 1 // Partial eclipse
        pattern = 0
        observational(c1)
        observational(c4)
        if (c1[40] == 0) { pattern += 100 }
        if (mid[40] == 0) { pattern += 10 }
        if (c4[40] == 0) { pattern += 1 }
        if (pattern == 110) {
          getsunset(elements,c4)
          observational(c4)
          c4[40] = 3
        } else if (pattern == 100) {
          getsunset(elements,mid)
          midobservational()
          mid[40] = 3
          copycircumstances(mid, c4)
        } else if (pattern == 11) {
          getsunrise(elements,c1)
          observational(c1)
          c1[40] = 2
        } else if (pattern == 1) {
          getsunrise(elements,mid)
          midobservational()
          mid[40] = 2
          copycircumstances(mid, c1)
        } else if (pattern == 0) {
          mid[39]=0
        }
        // There are other patterns, but those are the only ones we're covering!
      }
    } else {
      mid[39] = 0 // No eclipse
    }
    // Magnitude for total and annular eclipse is moon/sun ratio
    if ((mid[39] == 2) || (mid[39] == 3)) {
       mid[37] = mid[38]
    }
  }

// instead of reading form, we populate obsvconst with our data
function readform(lat, long, alt, timeOffset) {
    var tmp;

    // Set observer's constants manually
    // (0) North Latitude (radians): 39° 46' 00" N
    // (1) West Longitude (radians): 86° 09' 00" W
    // (2) Altitude (metres): 241.4m
    // (3) West time zone (hours): 05:00 W

    //lat_arr = ConvertDDToDMS(lat, false);
    // Latitude
    //var latDegrees = Math.abs(parseInt(lat_arr[deg])) //39;
    //console.log(latDegrees)
    //var latMinutes = Math.abs(parseInt(lat_arr[min]))//46;
    //var latSeconds = Math.abs(parseInt(lat_arr[sec]));
    var latDirection = 1; // 1 for North
    if (lat < 0){
        latDirection = -1} // south
    //obsvconst[0] = (latDirection * (latDegrees + latMinutes / 60.0 + latSeconds / 3600.0)) * (Math.PI / 180.0);
    obsvconst[0] = Math.abs(lat) 
    obsvconst[0] = obsvconst[0]*latDirection
    obsvconst[0]= obsvconst[0]*Math.PI/180.0


    //long_arr = ConvertDDToDMS(long, true);
    // Longitude
    //var lonDegrees = Math.abs(parseInt(long_arr[deg])) //86;
    //var lonMinutes = Math.abs(parseInt(long_arr[min]))//9;
    //var lonSeconds = Math.abs(parseInt(long_arr[sec]));
    var lonDirection = 1; // East
    if (long > 0) {
       lonDirection = -1; }// -1 for West
    //obsvconst[1] = (lonDirection * (lonDegrees + lonMinutes / 60.0 + lonSeconds / 3600.0)) * (Math.PI / 180.0);
    obsvconst[1] = Math.abs(long) * (Math.PI / 180.0);
    // Altitude
    obsvconst[2] = parseInt(alt)//241.4;

    // Time zone
    // Split the timeZone string by ':'
    //const parts = timeZone.split(':');

    // Extract hours and minutes
    //const hours = parseInt(parts[0], 10); // Parse hours as integer
    //const minutes = parseInt(parts[1], 10); // Parse minutes as integer

    //var timeZoneHours = 5
    //obsvconst[3] = minutes;
    //obsvconst[3] = hours + obsvconst[3]/60.0;
    //obsvconst[3]= 1 * obsvconst[3];
    obsvconst[3] = timeOffset

    // Get the observer's geocentric position
    tmp = Math.atan(0.99664719 * Math.tan(obsvconst[0]));
    obsvconst[4] = 0.99664719 * Math.sin(tmp) + (obsvconst[2] / 6378140.0) * Math.sin(obsvconst[0]);
    obsvconst[5] = Math.cos(tmp) + (obsvconst[2] / 6378140.0 * Math.cos(obsvconst[0]));

    console.log(obsvconst)
    // The index of the selected eclipse...
    // obsvconst[6] = 28 * (parseInt(document.eclipseform.index.options[document.eclipseform.index.selectedIndex].value) + 65);
}

// Get the local date of an event
function getdate(elements,circumstances) {
    var t, ans, jd, a, b, c, d, e, index
  
    index = obsvconst[6]
    // Calculate the JD for noon (TDT) the day before the day that contains T0
    jd = Math.floor(elements[index] - (elements[1+index]/24.0))
    // Calculate the local time (ie the offset in hours since midnight TDT on the day containing T0).
    t = circumstances[1] + elements[1+index] - obsvconst[3] - (elements[4+index] - 0.5) / 3600.0
    if (t < 0.0) {
      jd--;
    }
    if (t >= 24.0) {
      jd++;
    }
    if (jd >= 2299160.0) {
      a = Math.floor((jd - 1867216.25) / 36524.25)
      a = jd + 1 + a - Math.floor(a/4);
    } else {
      a = jd;
    }
    b = a + 1525.0
    c = Math.floor((b-122.1)/365.25)
    d = Math.floor(365.25*c)
    e = Math.floor((b - d) / 30.6001)
    d = b - d - Math.floor(30.6001*e)
    if (e < 13.5) {
      e = e - 1
    } else {
      e = e - 13
    }
    if (e > 2.5) {
      ans = c - 4716 + "-"
    } else {
      ans = c - 4715 + "-"
    }
    ans += month[e-1] + "-"
    if (d < 10) {
      ans = ans + "0"
    }
    ans = ans + d
    return ans
  }

// Get the local time of an event
// replaced document calls
function gettime(elements,circumstances) {
    var t, ans, index
  
    ans = ""
    index = obsvconst[6]
    t = circumstances[1] + elements[1+index] - obsvconst[3] - (elements[4+index] - 0.5) / 3600.0
    if (t < 0.0) {
      t = t + 24.0
    }
    if (t >= 24.0) {
      t = t - 24.0
    }
    if (t < 10.0) {
      ans = ans + "0"
    }
    ans = ans + Math.floor(t) + ":"
    t = (t * 60.0) - 60.0 * Math.floor(t)
    if (t < 10.0) {
      ans = ans + "0"
    }
    ans = ans + Math.floor(t)
    if (circumstances[40] <= 1) { // not sunrise or sunset
      ans = ans + ":"
      t = (t * 60.0) - 60.0 * Math.floor(t)
      if (t < 10.0) {
        ans = ans + "0"
      }
      ans = ans + Math.floor(t)
    }
    if (circumstances[40] == 1) {
      console.log("TIME: " + ans + " (below horizon)");
      return ans //+ " (below horizon)"
    } else if (circumstances[40] == 2) {
        console.log("TIME: " + ans + " (sunrise)");
        return ans //+ " (sunrise)"
    } else if (circumstances[40] == 3) {
        console.log("TIME: " + ans+"(sunset)");
        return ans //+"(sunset)";
    } else {
        console.log("TIME: " + ans);
        return ans
    }
  }
  
// Get the altitude
function getalt(circumstances) {
    var t, ans
  
    if (circumstances[40] == 2) {
      console.log("ALT: 0(sunrise)");
      return 
    }
    if (circumstances[40] == 3) {
        console.log("ALT: 0(sunset)");
        return 
    }
    if ((circumstances[32] < 0.0) && (circumstances[32] >= -0.00524)) {
      // Crude correction for refraction (and for consistency's sake)
      t = 0.0
    } else {
      t = circumstances[32] * 180.0 / Math.PI
    }
    if (t < 0.0) {
      ans = "-"
      t = -t
    } else {
      ans = ""
    }
    t = Math.floor(t+0.5)
    if (t < 10.0) {
      ans = ans + "0"
    }
    ans = ans + t
    if (circumstances[40] == 1) {
      console.log("ALT: " + ans + " (below horizon)");
      return
    } else {
        console.log("ALT :" + ans)
        return 
    }
  }

  // Get the azimuth
function getazi(circumstances) {
    var t, ans
  
    ans = ""
    t = circumstances[35] * 180.0 / Math.PI
    if (t < 0.0) {
      t = t + 360.0
    }
    if (t >= 360.0) {
      t = t - 360.0
    }
    t = Math.floor(t + 0.5)
    if (t < 100.0) {
      ans = ans + "0"
    }
    if (t < 10.0) {
      ans = ans + "0"
    }
    ans = ans + t
    if (circumstances[40] == 1) {
        console.log("AZI: " + ans + "(below horizon)");
        return 
    } else {
        console.log("AZI :" + ans);
        return 
    }
  }

// Get the duration in mm:ss.s format
//
// Adapted from code written by Stephen McCann - 27/04/2001
function getduration() {
    var tmp,ans;
    
    if (c3[40] == 4) {
      tmp = mid[1]-c2[1]
    } else if (c2[40] == 4) {
      tmp = c3[1]-mid[1]
    } else {
      tmp=c3[1]-c2[1];
    }
    if (tmp<0.0) {
      tmp=tmp+24.0
    } else if (tmp >= 24.0) {
      tmp=tmp-24.0
    }
    tmp=(tmp*60.0)-60.0*Math.floor(tmp)+0.05/60.0;
    ans=Math.floor(tmp)+"m"
    tmp=(tmp*60.0)-60.0*Math.floor(tmp)
    if (tmp < 10.0) {
      ans=ans+"0"
    }
    ans+=Math.floor(tmp)+"s"
    return ans
  }

// Get the magnitude
function getmagnitude() {
    var a
  
    a = Math.floor(1000.0*mid[37]+0.5)/1000.0
    if (mid[40] == 1) {
      console.log("MAGNITUDE: " + a + "(below horizon)")
      return a + "(below horizon)"
    }
    if (mid[40] == 2) {
      a = a + "(r)"
    }
    if (mid[40] == 3) {
      a = a + "(s)"
    }
    console.log("MAGNITUDE: " + a)
    return a 
  }

// Get the coverage
function getcoverage() {
    var a, b, c
  
    if (mid[37] <= 0.0) {
      a = "0.0"
    } else if (mid[37] >= 1.0) {
      a = "1.000"
    } else {
      if (mid[39] == 2) {
        c = mid[38] * mid[38]
      } else {
        c = Math.acos((mid[28]*mid[28] + mid[29]*mid[29] - 2.0*mid[36]*mid[36]) / (mid[28]*mid[28] - mid[29]*mid[29]))
        b = Math.acos((mid[28]*mid[29] + mid[36]*mid[36])/mid[36]/(mid[28]+mid[29]))
        a = Math.PI - b - c
        c = ((mid[38]*mid[38]*a + b) - mid[38]*Math.sin(c))/Math.PI
      }
      a = Math.floor(1000.0*c+0.5)/1000.0
    }
    if (mid[40] == 1) {
      console.log("COVERAGE: " + a + "(below horizon)")
      return a // + "(below horizon)"
    }
    if (mid[40] == 2) {
      a = a //+ "(r)"
    }
    if (mid[40] == 3) {
      a = a //+ "(s)"
    }
    console.log("COVERAGE: " + a)
    return a
  }

// CALCULATE!
function calculatefor(lat, long, alt, timeOffset, el) {
    returnList = []
    readform(lat, long, alt, timeOffset) // sets obsvconst
    console.log(obsvconst)
    for (i = 0 ; i < el.length ; i+=28) {
      obsvconst[6] = i
      getall(el)
      //console.log(mid)
      // Is there an event...
      if (mid[39] > 0) {
        console.log(getdate(el,mid))
        if (mid[39] == 1) {
         val = "P"
        } else if (mid[39] == 2) {
          val = "A"
        } else {
          val = "T"
        }
        console.log("ECILIPSE_TYPE: " + val)
        // Partial eclipse start
        if (c1[40] == 4) {
        } else {
        // Partial eclipse start time -----------------
        getT = gettime(el,c1)
        if (getT == "" || getT == null || getT == undefined){
          getT = "N/A"
         }
        console.log(getT);
        returnList.push(getT + "ec_start"); 
        // Partial eclipse alt
        console.log(getalt(c1));
        }
      // Central eclipse time  -------------------------
      if ((mid[39] > 1) && (c2[40] != 4)) {
          getT = gettime(el,c2);
          if (getT == "" || getT == null || getT == undefined) {
            getT = "N/A"
          }
          console.log(getT);
          returnList.push(getT + "tot_start"); 
      } else {
      }
      // Maximum eclipse time -------------------------
      getT = gettime(el,mid);
      if (getT == "" || getT == null || getT == undefined) {
        getT = "N/A"
      }
      console.log(getT);
      returnList.push(getT + "max_ec"); 
      // Maximum eclipse alt
      console.log(getalt(mid));
      // Maximum eclipse azi
      console.log(getazi(mid));
      // Central eclipse ends
      if ((mid[39] > 1) && (c3[40] != 4)) {
        console.log(gettime(el,c3));
      } else {
      }
        // Partial eclipse ends
        if (c4[40] == 4) {
        } else {
        // Partial eclipse ends
        console.log(gettime(el,c4));
        // ... sun alt
        console.log(getalt(c4));
        }
      // Eclipse magnitude ---------------------------
      console.log(getmagnitude());
      returnList.push(getmagnitude() + "mag"); 
      // Coverage  ------------------------------------
      console.log(getcoverage());
      returnList.push(getcoverage() + "obsc");
      // Central duration
      if (mid[39] > 1) {
        val = getduration();
      } else {
        val = "-";
      }
      console.log(val);
      }
    }
    var resultString = returnList.join(' ');
    console.log(resultString);
    return resultString;
  }

  function settimeperiod(timeperiod) {
    for (i = 0 ; i < loadedtimeperiods.length ; i++) {
      if (loadedtimeperiods[i] == timeperiod) {
        if (eval("self."+timeperiod)) {
          currenttimeperiod = timeperiod;
          eval(timeperiod+"()");
        }
        return;
      }
    }
    currenttimeperiod = timeperiod;
    loadedtimeperiods.push(timeperiod);
    // RUN timeperiod.js
    SE2001();
  }

  function recalculate(lat, long, alt, timeOffset) {
    return SE2001(lat, long, alt, timeOffset)
  }

// IMPORTANT CUT --------------------------------------------------------------------------------------------------------------------------
//
// Besselian Elements for Solar Eclipses from:
//   "Five Millennium Canon of Solar Eclipses: -1999 to +3000",
//      Fred Espenak and Jean Meeus, NASA/TP-2006-214141, October 2006
//
function SE2001(lat, long, alt, timeOffset) {
    return calculatefor(lat, long, alt, timeOffset, new Array(
  // 2024  4  8
  2460409.262840,  18.0,  -4.0,   4.0,    74.0,    74.0,
    -0.3182440,   0.5117116,  3.260e-05, -8.420e-06,
     0.2197640,   0.2709589, -5.950e-05, -4.660e-06,
     7.5862002,   0.0148440, -2.000e-06,
    89.5912170,  15.0040817,  0.000e-00,
     0.5358140,   0.0000618, -1.280e-05,
    -0.0102720,   0.0000615, -1.270e-05,
     0.0046683,   0.0046450,
  ));}

  //function ConvertDDToDMS(D, lng) {
  //  return {
  //    dir: D < 0 ? (lng ? "W" : "S") : lng ? "E" : "N",
  //    deg: 0 | (D < 0 ? (D = -D) : D),
  //    min: 0 | (((D += 1e-9) % 1) * 60),
  //    sec: (0 | (((D * 60) % 1) * 6000)) / 100,
  //  };
  //}

recalculate(-86.5, 10.0, 250, 0);

let lat = parseFloat(process.argv[2]);
let long = parseFloat(process.argv[3]);
let alt = parseFloat(process.argv[4]);
let timeoffset = parseFloat(process.argv[5]);

let output = recalculate(lat, long, alt, 0);
console.log(JSON.stringify({ "magnitude": output }));