<template>
    <div>
        <div v-if="!enrollmentPending">
            <p class="text-sm text-gray-400">Studying</p>
            <h1>{{enrollment.subject.title}}</h1>
            <hr class="mb-8">

            <template v-if="currentSection">
                <p class="text-xs text-gray-400">Section</p>
                <h1>{{ currentSection.title }}</h1>
                <hr>
            </template>

            <component v-if="!isAtEnd" class="mt-8"
             :is="getComponentFromType(enrollment.block_cursor.type)"
             :block="enrollment.block_cursor"
             @consume="consumeBlock" />
            <div v-else>You've reached the end of the course, congrats!!</div>

            <p class="text-xs text-gray-400 mt-8">Navigation</p>
            <hr class="">

            <div class="mt-8">
                <template v-for="section in enrollment.subject.sections">
                    <h2 class="underline mb-2">{{ section.title }}</h2>
                    <p v-for="block in section.blocks" @click="moveCursor(block.id)"
                       class="text-sm mb-2">{{block.order_in_section}} | {{ getComponentTypeName(block.type) }}</p>
                </template>
            </div>
        </div>
        <ScaleLoader v-else height="10px" width="2px" />
    </div>
</template>

<script setup>
    import ScaleLoader from 'vue-spinner/src/ScaleLoader.vue';
    import StudyBlockStatic from '@/components/studyBlock/Static.vue';
    import StudyBlockMCQ from '@/components/studyBlock/MCQ.vue';
    import StudyBlockSAQ from '@/components/studyBlock/SAQ.vue';
    import StudyBlockFC from '@/components/studyBlock/FC.vue';
    import StudyBlockFIBQ from '@/components/studyBlock/FIBQ.vue';

    const route = useRoute();

    const enrollmentId = route.params.enrollmentId;
    const student = "nikokozak@gmail.com";

    const { data: enrollment, pending: enrollmentPending } = useFetchAPI(`/api/pages/study/${enrollmentId}`, {key: enrollmentId})

    const currentSection = computed(() => enrollment.value?.block_cursor?.section);
    const isAtEnd = computed(() => enrollment.value?.block_cursor == null)

    function getComponentFromType(type) {
        switch(type) {
            case "static": return StudyBlockStatic
            case "mcq": return StudyBlockMCQ
            case "saq": return StudyBlockSAQ
            case "fc": return StudyBlockFC
            case "fibq": return StudyBlockFIBQ

        }
    }

    function consumeBlock(answers) {
        useConsumeCursor(enrollment, answers).then(updatedEnrollment => {
            enrollment.value.block_cursor = updatedEnrollment.block_cursor;
        })
    }

    function moveCursor(newCursorId) {
        useMoveCursor(enrollment, newCursorId).then(updatedEnrollment => {
            enrollment.value.block_cursor = updatedEnrollment.block_cursor
        })
    }

    function getComponentTypeName(type) {
        switch(type) {
            case "static": return "Text Content"
            case "mcq": return "Multiple-Choice Question"
            case "saq": return "Single Answer Question"
            case "fc": return "Flash Card"
            case "fibq": return "Fill in the Blank Question"
        }
    }
</script>
