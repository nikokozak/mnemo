<script>
    import SubjectInfo from './_subject_info.svelte';
    import SubjectSections from './_subject_sections.svelte';
    import debounce from 'lodash/debounce';

    /** DATA **/
 
    export let subject = {};
    let sections = [];
    let deleteSubjectRoute = '/api/content/delete/' + subject.id;

    /** HANDLERS **/

    const handleInput = debounce(e => {
        saveContent();
    }, 500);

</script> 

<SubjectInfo bind:subject={subject} />

<SubjectSections bind:sections={sections} />

<h1 class="text-sm text-gray-400 mt-12">subject options</h1>
<hr class="border-gray-400">

<a href={deleteSubjectRoute} class="block py-2 px-4 border border-red-400 rounded-lg mt-4 w-40 text-xs">
    Delete Subject
</a>
