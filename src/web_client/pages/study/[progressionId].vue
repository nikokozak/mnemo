<template>
    <div>
        <p class="text-sm text-gray-400">Studying</p>
        <h1>{{progression?.subject?.title}}</h1>
        <hr class="mb-8">

        <template v-if="progression?.current_section">
            <p class="text-xs text-gray-400">Section</p>
            <h1>{{ progression?.current_section?.title }}</h1>
            <hr>
        </template>

        <component v-if="!progressionPending" class="mt-8"
         :is="getComponentFromType(progression.content_block_cursor.type)"
         :contentBlock="progression.content_block_cursor" />

    </div>
</template>

<script setup>
    import StudyBlockStatic from '@/components/studyBlock/Static.vue'

    const route = useRoute();

    const progressionId = route.params.progressionId;
    const student = "nikokozak@gmail.com";

    const { data: progression, pending: progressionPending } = useFetchAPI(`/api/progressions/${progressionId}`, {key: progressionId})
    const current_section = computed(() => progression?.current_section);

    function getComponentFromType(type) {
        switch(type) {
            case "static": return StudyBlockStatic
        }
    }
</script>
