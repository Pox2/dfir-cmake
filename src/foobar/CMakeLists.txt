#find_package(chakracore REQUIRED)
#find_package(ssdeep CONFIG REQUIRED)
find_package(7zip CONFIG REQUIRED)
#find_package(ApacheOrc REQUIRED)
#find_package(Parquet REQUIRED)
find_package(VisualStudio REQUIRED)
find_package(Yara REQUIRED)
find_package(boost REQUIRED)
find_package(fmt REQUIRED)
find_package(tlsh CONFIG REQUIRED)

add_executable(foobar
    main.cpp
)
