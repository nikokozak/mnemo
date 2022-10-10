<template>
    <div class="mt-12">
        <div class="flex justify-between">
            <h1 class="text-sm text-gray-400">subject options</h1>
        </div>
        <hr class="border-gray-400 mb-4">

        <button @click="showDeleteModal = true" 
            class="px-4 py-2 text-sm border border-red-600 rounded-lg">
            Delete Subject
        </button>
    </div>

    <Teleport to="body">
        <Modal :show="showDeleteModal">
            <template #header>
                Delete Subject
            </template>
            <template #body>
                Are you sure you want to delete this section?
            </template>
            <template #footer>
                <div class="flex w-full justify-between">
                    <button @click="deleteSubject"
                        class="px-4 py-2 border rounded-lg border-red-500">Delete</button>
                    <button @click="showDeleteModal = false"
                        class="px-4 py-2 border rounded-lg border-blue">Cancel</button>
                </div>
            </template>
        </Modal>
    </Teleport>
</template>

<script setup>
    import { ref } from 'vue';

    const config = useRuntimeConfig();
    const props = defineProps(['subjectId']);
    const subjectId = props.subjectId;
    const student = "nikokozak@gmail.com";
    const showDeleteModal = ref(false);

    function deleteSubject() {
        useFetch(`${config.public.baseURL}/api/subjects/${subjectId}`, {
            method: 'DELETE'
        }).then(response => {
            window.location.href = '/student';
        });
    }
</script>
