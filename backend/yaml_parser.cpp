#include "yaml_parser.hpp"
#include <yaml-cpp/yaml.h>
#include <boost/filesystem.hpp>
#include <fstream>

std::vector<Email> loadEmails(const std::string& directory) {
    std::vector<Email> emails;
    namespace fs = boost::filesystem;

    for (const auto& entry : fs::directory_iterator(directory)) {
        if (fs::is_regular_file(entry) && entry.path().extension() == ".yaml") {
            YAML::Node emailNode = YAML::LoadFile(entry.path().string());
            Email email;
            email.from = emailNode["from"].as<std::string>();
            email.to = emailNode["to"].as<std::string>();
            email.subject = emailNode["subject"].as<std::string>();
            email.date = emailNode["date"].as<std::string>();
            email.body = emailNode["body"].as<std::string>();
            emails.push_back(email);
        }
    }

    return emails;
}

