#include "yaml_parser.hpp"
#include <crow.h>
#include <sstream>

int main() {
    crow::SimpleApp app;

    // 存档目录
    const std::string archiveDir = "/opt/yaml_archives/";

    // 首页路由
    CROW_ROUTE(app, "/")
    ([]() {
        std::stringstream html;
        html << "<html><head><title>Email Archives</title></head><body>";
        html << "<h1>Email Archives</h1>";
        html << "<ul>";
        html << R"(<li><a href="/list">View Archives</a></li>)";
        html << "</ul></body></html>";
        return html.str();
    });

    // 列出所有存档
    CROW_ROUTE(app, "/list")
    ([&]() {
        auto emails = loadEmails(archiveDir);
        std::stringstream html;
        html << "<html><head><title>Email List</title></head><body>";
        html << "<h1>Email List</h1><ul>";
        for (size_t i = 0; i < emails.size(); ++i) {
            html << "<li><a href=\"/archive/" << i << "\">" << emails[i].subject << "</a></li>";
        }
        html << "</ul></body></html>";
        return html.str();
    });

    // 查看单个存档
    CROW_ROUTE(app, "/archive/<int>")
    ([&](int id) {
        auto emails = loadEmails(archiveDir);
        if (id < 0 || id >= static_cast<int>(emails.size())) {
            return crow::response(404, "Email not found");
        }

        const auto& email = emails[id];
        std::stringstream html;
        html << "<html><head><title>" << email.subject << "</title></head><body>";
        html << "<h1>" << email.subject << "</h1>";
        html << "<p><strong>From:</strong> " << email.from << "</p>";
        html << "<p><strong>To:</strong> " << email.to << "</p>";
        html << "<p><strong>Date:</strong> " << email.date << "</p>";
        html << "<hr><p>" << email.body << "</p></body></html>";
        return html.str();
    });

    // 启动服务
    app.port(8080).multithreaded().run();

    return 0;
}

