document.addEventListener("DOMContentLoaded", () => {
    fetch("/")
        .then(response => response.json())
        .then(files => {
            const list = document.getElementById("archive-list");
            files.forEach(file => {
                const li = document.createElement("li");
                li.textContent = file;
                li.addEventListener("click", () => {
                    fetch(`/archive/${file}`)
                        .then(response => response.json())
                        .then(data => {
                            const content = document.getElementById("archive-content");
                            content.innerHTML = `<h2>${data.subject}</h2><p>${data.body}</p>`;
                        });
                });
                list.appendChild(li);
            });
        });
});

