module Factory
    def self.non_matching_paths
        [
            "/AppTest/ClassTest.jpg",
            "ClassTest.h",
            "ClassTestClass.m",
            "/FolderABC/OneMoreClass.swift",
        ]
    end

    def self.matching_paths
        [
            "/AppTest/ClassTest.swift",
            "AnotherClassSpec.m",
            "/FolderABC/OneMoreClassTest.swift",
        ]
    end

    def self.duplicate_paths
        [
            "AppTests/ClassTest.swift",
            "ClassTest.m",
            "App/ClassTest.swift",
        ]
    end
end