<template>
    <div>
        <div id="student-review-section">
        </div>

        <div id="student-continue-learning-section">
        </div>

        <div id="student-subjects-section">
          <h1 class="text-lg font-semibold mb-2">my subjects</h1>
          <hr>
          <!-- Subject List -->
          <ScaleLoader v-if="pending" />
          <template v-else v-for="subject in subjects">
              <NuxtLink :to="'/subject/' + subject.id">
                  <div class="border px-2 py-1 rounded-lg mt-4 flex justify-between">
                      <p class="text-md">{{ subject.title }}</p>
                      <p class="text-sm text-slate-900">{{ subject.published }}</p>
                    <p class="text-sm text-slate-900">editicon</p>
                  </div>
              </NuxtLink>
          </template>
          <!-- end Subject List -->

          <button @click="createSubject" id="student-subjects-new-link" class="block border rounded-lg py-1 px-2 mt-4">
              Create a new Subject to study.
          </button>
        </div>
    </div>
</template>

<script setup>
import ScaleLoader from 'vue-spinner/src/ScaleLoader.vue';
import { ref, reactive } from 'vue';

const config = useRuntimeConfig();
const student = "nikokozak@gmail.com";
const { data: subjects, pending } = await useFetch(`${config.public.baseURL}/api/student/${student}/subjects`, { server: false });

function createSubject() {
    $fetch(`${config.public.baseURL}/api/subjects/`, {
        method: 'POST',
        body: { student_id: student }
    }).then(response => {
            console.log(`created subject ${ response.id }`);
            window.location.href = `/subject/${ response.id }`;
        });
}
</script>
