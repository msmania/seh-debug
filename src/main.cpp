#include <gtest/gtest.h>
#include <gmock/gmock.h>

TEST(test_case_name, test_name) {
}

int main(int argc, char **argv) {
  ::testing::InitGoogleTest(&argc, argv);
  return RUN_ALL_TESTS();
}