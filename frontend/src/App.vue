<template>
  <v-container>
    <v-card>
      <v-card-title>Email List Management</v-card-title>
      <v-card-text>
        <v-text-field v-model="listName" label="List Name"></v-text-field>
        <v-text-field v-model="ownerEmail" label="Owner Email"></v-text-field>
        <v-btn color="primary" @click="createList">Create List</v-btn>
      </v-card-text>
    </v-card>

    <v-card v-for="list in emailLists" :key="list">
      <v-card-text>{{ list }}</v-card-text>
    </v-card>
  </v-container>
</template>

<script lang="ts">
import { defineComponent, ref } from "vue";

export default defineComponent({
  setup() {
    const listName = ref("");
    const ownerEmail = ref("");
    const emailLists = ref<string[]>([]);

    const createList = async () => {
      await fetch("/api/create_list/", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name: listName.value, owner: ownerEmail.value }),
      });
      fetchLists();
    };

    const fetchLists = async () => {
      const response = await fetch("/api/lists/");
      const data = await response.json();
      emailLists.value = data.lists;
    };

    fetchLists();
    return { listName, ownerEmail, emailLists, createList };
  },
});
</script>

