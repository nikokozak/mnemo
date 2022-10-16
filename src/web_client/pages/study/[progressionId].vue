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

        <component v-if="!progressionPending && !isAtEnd" class="mt-8"
         :is="getComponentFromType(progression.content_block_cursor.type)"
         :contentBlock="progression.content_block_cursor"
         @consume="consumeBlock" />
        <div v-else>You've reached the end of the course, congrats!!</div>

        <hr class="mt-8">

        <div class="mt-8">
            <template v-for="section in subjectSections">
                <h2 class="underline mb-2">{{ section.title }}</h2>
                <p v-for="block in section.blocks"
                   class="text-sm mb-2">{{block.order_in_section}} | {{ getComponentTypeName(block.type) }}</p>
            </template>
        </div>

    </div>
</template>

<script setup>
    import StudyBlockStatic from '@/components/studyBlock/Static.vue'
    import StudyBlockMCQ from '@/components/studyBlock/MCQ.vue'

    const route = useRoute();

    const progressionId = route.params.progressionId;
    const student = "nikokozak@gmail.com";

    const isAtEnd = computed(() => {
        return progression?.value?.cursor_at_end;
    })

    const { data: progression, pending: progressionPending, refresh: refreshProgression } = useFetchAPI(`/api/progressions/${progressionId}`, {key: progressionId})
    const { data: subjectSections, pending: subjectSectionsPending } = useFetchAPI(`/api/progressions/${progressionId}/sections_and_blocks`)
    const current_section = computed(() => progression?.current_section);

    function getComponentFromType(type) {
        switch(type) {
            case "static": return StudyBlockStatic
            case "mcq": return StudyBlockMCQ
        }
    }

    function consumeBlock({contentBlock, answers}) {
        useSimpleFetch(`/api/progressions/consume`, {
            key: progressionId,
            method: 'POST',
            body: {
                progression_id: progressionId,
                content_block_id: contentBlock.id,
                answers: answers
            }
        }).then(response => {
            refreshProgression()
        })
    }

    function getComponentTypeName(type) {
        switch(type) {
            case "static": return "Text Content"
            case "mcq": return "Multiple-Choice Question"
        }
    }
</script>
