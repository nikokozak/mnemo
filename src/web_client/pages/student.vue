<template>
    <div>
        <div id="student-review-section">
        </div>

        <div id="student-continue-learning-section">
        </div>

        <div id="student-study-section" class="mb-12">
          <h1 class="text-lg font-semibold mb-2">currently studying</h1>
          <hr>
          <!-- Progressions List -->
          <ScaleLoader :height="'15px'" :width="'2px'" class="mt-6" v-if="subjects_pending" />
          <template v-else v-for="progression in progressions">
              <div class="border px-2 py-1 rounded-lg mt-4 flex justify-between">
                  <p class="text-md">{{ progression.subject.title }}</p>
                  <button @click="deleteEnrollment(progression.id)" class="text-xs text-slate-900 border rounded-lg px-2">
                      Unenroll
                  </button>
                  <NuxtLink :to="'/study/' + progression.id" class="text-xs text-slate-900 border rounded-lg px-2 py-1">
                      Study Now
                  </NuxtLink>
              </div>
          </template>
          <!-- end Subject List -->
        </div>

        <div id="student-subjects-section">
          <h1 class="text-lg font-semibold mb-2">my subjects</h1>
          <hr>
          <!-- Subject List -->
          <ScaleLoader :height="'15px'" :width="'2px'" class="mt-6" v-if="subjects_pending" />
          <template v-else v-for="subject in subjects">
              <div class="border px-2 py-1 rounded-lg mt-4 flex justify-between">
                  <p class="text-md">{{ subject.title }}</p>
                  <template v-if="enrolled_subject_ids.includes(subject.id)">
                      <p>Enrolled</p>
                  </template>
                  <template v-else>
                      <button @click="enroll(subject.id)" class="text-xs text-slate-900 border rounded-lg px-2">
                          Start Studying
                      </button>
                  </template>
                  <NuxtLink :to="'/subject/' + subject.id">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
                      <path stroke-linecap="round" stroke-linejoin="round" d="M16.862 4.487l1.687-1.688a1.875 1.875 0 112.652 2.652L10.582 16.07a4.5 4.5 0 01-1.897 1.13L6 18l.8-2.685a4.5 4.5 0 011.13-1.897l8.932-8.931zm0 0L19.5 7.125M18 14v4.75A2.25 2.25 0 0115.75 21H5.25A2.25 2.25 0 013 18.75V8.25A2.25 2.25 0 015.25 6H10" />
                  </svg>
                  </NuxtLink>
              </div>
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

const student = "nikokozak@gmail.com";
const { data: subjects, pending: subjects_pending } = await useFetchAPI(`/api/student/${student}/subjects`, {key: "subjects"});
const { 
    data: progressions,
    pending: progressions_pending,
    refresh: progressions_refresh 
} = await useFetchAPI(`/api/student/${student}/progressions`, {key: "progressions"});

const enrolled_subject_ids = computed(() => {
    if (!progressions_pending.value) {
        return progressions.value.map(p => p.subject.id)
    } else {
        return [];
    }
})

function enroll(subject_id) {
    useSimpleFetch(`/api/progressions`, {
        method: 'POST',
        body: { student_id: student, subject_id: subject_id }
    }).then(response => {
        console.log(`created progression ${ response.id }`);
        progressions_refresh();
    });
}

function deleteEnrollment(progression_id) {
    useSimpleFetch(`/api/progressions/${progression_id}`, {
        method: 'DELETE',
    }).then(response => {
        progressions_refresh();
    });
}

function createSubject() {
    useSimpleFetch(`/api/subjects/`, {
        method: 'POST',
        body: { student_id: student }
    }).then(response => {
            console.log(`created subject ${ response.id }`);
            window.location.href = `/subject/${ response.id }`;
        });
}
</script>
