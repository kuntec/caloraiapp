import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const kPrimaryColor = Color(0xFF273958);
const kSecondaryColor = Color(0xFF989EA7);

// const kMainThemeColor = Color(0xFF2360FF);
const kMainThemeColor = Color(0xFF0C9BD7);
//const kMainThemeColor = Color(0xFFAF885C);

const primaryOrangeLight = Color(0xFFFFA500);
const primaryOrangeDark = Color(0xFFFF8800);
const primaryGreenLight = Color(0xFF64DE4B);
const primaryGreenDark = Color(0xFF009343);

const bg = Color(0xFFFFFFFF);
const primary = Color(0xFFFF8800);
const primary2 = Color(0xFFFFA500);
const textPrimary = Color(0xFF1F2937);
const textSecondary = Color(0xFF6B7280);

const border = Color(0xFFE5E7EB);

const redColor = Color(0xFFFF0000);

const kLargeText = 18.0;
const kMediumText = 16.0;
const kSmallText = 14.0;
const kExtraSmallText = 12.0;

dynamic googleFont = GoogleFonts.poppins();
const kAppName = "LMS";
const kMyStudents = "My Students";
const kAddStudent = "Add Student";
const kAddSchedule = "Add Schedule";
const kMySchedule = "My Schedule";
const kAttendance = "Attendance";
const kMyCourses = "My Courses";
const kAddCourses = "Add Courses";
const kAddChapter = "Add Chapter";
const kCourseDetails = "Course Details";
const kMessages = "Messages";
const kAiCourses = "AI Courses";
const kGenerateAiCourses = "Generate Courses";

const colorCodes = [
  0xFF3DB2FF,
  0xFF004AAD,
  0xFFFF9CEE,
  0xFF880E4F,
  0xFFFFC371,
  0xFFB34700,
  0xFF66E5A1,
  0xFF0BAB64,
  0xFF3DB2FF,
  0xFF004AAD,
  0xFFFF9CEE,
  0xFF880E4F
];

final List<List<int>> gradientColors = [
  [0xFF3DB2FF, 0xFF004AAD],
  [0xFFFF9CEE, 0xFF880E4F],
  [0xFFFFC371, 0xFFB34700],
  [0xFF66E5A1, 0xFF0BAB64],
  [0xFFFFA17F, 0xFF00223E],
  [0xFF3DB2FF, 0xFF004AAD],
  [0xFFFF9CEE, 0xFF880E4F],
];

var kTitleTextStyle = GoogleFonts.poppins(
  textStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
);

var kContainerBox = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(15.0),
  border: Border.all(
    color: Colors.white,
    width: 1.0,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      offset: Offset(0, 2),
      blurRadius: 6.0,
    ),
  ],
);

var kContainerBoxPlain = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(15.0),
  border: Border.all(
      //color: Colors.grey,
      //width: 1.0,
      ),
  boxShadow: [
    BoxShadow(
      color: Colors.black12,
      offset: Offset(0, 2),
      blurRadius: 6.0,
    ),
  ],
);
