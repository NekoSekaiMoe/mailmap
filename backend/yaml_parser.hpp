#ifndef YAML_PARSER_HPP
#define YAML_PARSER_HPP

#include <string>
#include <vector>
#include <unordered_map>

struct Email {
    std::string from;
    std::string to;
    std::string subject;
    std::string date;
    std::string body;
};

std::vector<Email> loadEmails(const std::string& directory);

#endif // YAML_PARSER_HPP

